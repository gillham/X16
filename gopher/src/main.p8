; Prog8 options
%encoding iso
%zeropage basicsafe
%option no_sysinit

; Prog8 libraries
%import conv
%import strings
%import textio

; local modules
%import gopher
%import input
%import libnet
%import socket
%import stack
%import term

main {
    uword url = memory("url", 1 * 256, 256)

    ; some defines for return codes
    const ubyte G_EXIT = $ff
    const ubyte G_RELOAD = $fe
    const ubyte G_BACK = $fd

    ; array index for special go back choice
    const ubyte BACK_CHOICE = gopher.MAX_LINES ; not +1 because zero relative
    ; stack index
    ubyte idx

    sub start() {
        term.init()

        txt.column(5)
        txt.row(3)
        txt.print("What site? ")
        void txt.input_chars(url)
        txt.nl()

        if net.load() {
            ; push to index 0 of stack
            ; this should be our "root" that stays?
            stack.set_type(0, '1')
            stack.set_selector(0, "")
            stack.set_server(0, url)
            stack.set_port(0, conv.str_uw(gopher.TCP_PORT))

            ; push additional times for testing.
            repeat 2 {
            ; make initial request
            ; push it to stack to
            ; simulate going back to it.
            idx = stack.push()
            ;txt.print("stack idx: ")
            ;txt.print_ubhex(idx, false)
            ;txt.nl()
            stack.set_type(idx, '1')
            stack.set_selector(idx, "")
            stack.set_server(idx, url)
            stack.set_port(idx, conv.str_uw(gopher.TCP_PORT))
            }
            gopher.types[BACK_CHOICE] = stack.get_type(idx)
            gopher.selectors[BACK_CHOICE] = stack.get_selector(idx)
            gopher.servers[BACK_CHOICE] = stack.get_server(idx)
            gopher.ports[BACK_CHOICE] = stack.get_port(idx)

            void gopher.getmenu(BACK_CHOICE)

            ; use $ff to signal quit.
            ubyte choice = $00

            repeat {
                term.clear()
                txt.column(0)
                txt.row(1)
                gopher.menudraw()
                gopher.select_line(gopher.selected_line)
                choice = gopher.menu()

                when choice {
                    G_BACK -> go_back(false)
                    G_EXIT -> {
                        ; TODO: get confirmation
                        ; and cleanup networking before exiting
                        txt.nl()
                        txt.print(" Exiting... ")
                        txt.nl()
                        break
                    }
                    G_RELOAD -> {
                        txt.nl()
                        txt.row(30)
                        txt.print(" Restart here... ")
                        txt.nl()
                        sys.wait(120)   ; reload status message
                        go_back(true)   ; reloads current location
                    }
                    else -> {
                        ; always push to stack
                        ; so back works
                        idx = stack.push()
                        stack.set_type(idx, gopher.types[choice])
                        stack.set_selector(idx, gopher.selectors[choice])
                        stack.set_server(idx, gopher.servers[choice])
                        stack.set_port(idx, gopher.ports[choice])

                        void gopher.handler(choice)
                        if gopher.types[choice] != gopher.TYPE_DIRECTORY
                            go_back(false)
                    }
                 }
            }
            ; cleanup
            socket.close(0)

        } else {
            txt.print("Network library load failed.")
            txt.nl()
            txt.print("Try: LOAD\"NET.BIN\" manually.")
            txt.nl()
        }
    }

    sub go_back(bool reload) {
        ; first on the stack is self
        ; toss it because we are going back.
        if not reload
            void stack.pop()
        ; now we have our parent at top
        ; just peek it since it will be our current
        idx = stack.top()

        ;
        ; handle going to previous menu
        ; pop details from stack
        ; stuff into gopher arrays at G_BACK index
        ; call gopher.handler(G_BACK)
        gopher.types[BACK_CHOICE] = stack.get_type(idx)
        gopher.selectors[BACK_CHOICE] = stack.get_selector(idx)
        gopher.servers[BACK_CHOICE] = stack.get_server(idx)
        gopher.ports[BACK_CHOICE] = stack.get_port(idx)
        void gopher.handler(BACK_CHOICE)
    }

    sub dumpbuffer() {
        ; debug... we need to see the buffer.
        ubyte m
        ubyte n
        ubyte char

        ; start of buffer
        input.pos = 0

        txt.nl()
        txt.column(1)
        for m in 1 to 35 {
            if input.eof()
                break
            for n in 1 to 80 {
                if input.eof()
                    break
                char = input.next()
                when char {
                    $00 -> txt.spc()
                    $09 -> txt.print("TAB")
                    $0a -> {
                        txt.print("LF")
                        break
                    }
                    $0d -> {
                        txt.print("CR")
                    }
                    else -> txt.chrout(char)
                }
                ;txt.print_ubhex(char, false)
                ;txt.chrout(' ')
            }
            txt.nl()
            txt.column(1)
        }
        txt.nl()
        txt.column(1)
        txt.print("POS: ")
        txt.print_uwhex(input.pos, false)
        txt.nl()
        txt.column(1)
        txt.print("CNT: ")
        txt.print_uwhex(input.cnt, false)
        input.pos = 0
    }

    sub dumpbufferhex() {
        ; debug... we need to see the buffer.
        ubyte m
        ubyte n
        ubyte char

        ; start of buffer
        input.pos = 0
        txt.nl()
        txt.column(1)

        for m in 1 to 20 {
            if input.eof()
                break
            for n in 1 to 20 {
                if input.eof()
                    break
                char = input.next()
                txt.print_ubhex(char, false)
                txt.chrout(' ')
            }
            txt.nl()
            txt.column(1)
        }
        txt.nl()
        txt.column(1)
        txt.print("POS: ")
        txt.print_uwhex(input.pos, false)
        txt.nl()
        txt.column(1)
        txt.print("CNT: ")
        txt.print_uwhex(input.cnt, false)
        input.pos = 0
    }

    sub getdata() {
        ; poll data loop (until server disconnects)
        repeat {
            sys.set_irqd()
            net.net_poll()
            sys.clear_irqd()

            ; check connected state first as
            ; socket status won't be valid
            ; after socket.recv()
            if net.poll.socket[0] & net.SOCK_STAT_HAS_DATA == 0 {
                ; no data & disconnected means we are done here..
                if (net.poll.socket[0] & net.SOCK_STAT_CONNECTED) == 0 {
                    break
                }
                ; send null for now to detect socket disconnect
                ; fixed in next firmware.  cleanup eventually
                void socket.send_byte(0, $00)
                term.statusline.twiddle()
            } else {
                input.cnt += socket.recv(0, 255, input.buf + input.cnt)
                term.statusline.twiddle()
            }
        }
        term.statusline.twiddleoff()
    }
}
