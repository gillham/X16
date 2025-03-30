; Prog8 options
%encoding iso
%zeropage basicsafe

; Prog8 libraries
%import conv
%import strings
%import textio

; local modules
%import gopher
%import input
%import libnet
%import stack

main {
    uword buf = memory("receive", 1 * 256, 256)
    uword url = memory("url", 1 * 256, 256)

    ; timeout for polling/receiving data
    ubyte poll_count = 0

    ; colors for gopher UI
    const ubyte colors_normal = $b3
    const ubyte colors_selected = $d0

    ; some defines for return codes
    const ubyte G_EXIT = $ff
    const ubyte G_RELOAD = $fe
    const ubyte G_BACK = $fd

    ; array index for special go back choice
    const ubyte BACK_CHOICE = gopher.MAX_LINES ; not +1 because zero relative
    ; stack index
    ubyte idx

    sub start() {
        ; init screen/colors
        cx16.set_screen_mode(0)
        ;cx16.set_screen_mode(8)
        txt.lowercase()
        txt.iso()
        txt.color2(colors_normal & 15, colors_normal>>4)
        txt.clear_screen()

        txt.column(5)
        txt.row(1)
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
                txt.clear_screen()
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
                        sys.wait(120)
                        go_back(true)   ; reloads current location
                    }
                    else -> {
                        ; always push to stack
                        ; so back works
                        idx = stack.push()
                        ;txt.print("stack idx: ")
                        ;txt.print_ubhex(idx, false)
                        ;txt.nl()
                        ;sys.wait(120)
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

        } else {
            txt.print("Network library load failed.")
            txt.nl()
            txt.print("Try: LOAD\"NET.BIN\" manually.")
            txt.nl()
        }
    }

    sub close_socket() {
        net.close.socket = 0
        net.net_close()
    }

    sub open_socket(uword port) {
        ; IPv4
        net.open.ip_ty = net.IP_V4
;        net.open.ip[0] = 192
;        net.open.ip[1] = 168
;        net.open.ip[2] = 70
;        net.open.ip[3] = 10
        net.open.socket_arg0 = lsb(port)
        net.open.socket_arg1 = msb(port)
        ; socket = 0?
        net.open.socket = 0
        ; tcp socket
        net.open.socket_ty = net.SOCK_TCP
        net.net_open()
    }

    sub poll_open() -> bool {
        ; poll for socket open for 10 seconds
        ; return as soon as connected
        repeat 60 {
            sys.set_irqd()
            net.net_poll()
            sys.clear_irqd()
            if (net.poll.socket[0] & net.SOCK_STAT_CONNECTED) as bool
                return true
            sys.wait(10)
        }
        ; debug
        txt.nl()
        txt.print("   socket failed to open...")
        txt.nl()
        sys.wait(30)
        return false
    }

    ;
    ; this should eventually receive directly into
    ; input.buf and add recv_sz to input.cnt
    ;
    sub recv_data() {
        ubyte i
        net.recv.socket = 0
        net.recv.buf_sz = 255
        net.recv.buf_sz = 255
        net.recv.buf = buf
        sys.set_irqd()
        net.net_recv()
        sys.clear_irqd()
        if net.recv.recv_sz == 0 {
            return
        }
        for i in 0 to net.recv.recv_sz-1 {
            input.add(buf[i])
        }
    }

    sub send_byte(ubyte data) {
        net.send.socket = 0
        net.send.buf_sz = 1
        net.send.buf = &data
        net.net_send()
    }

    sub send_string(uword data) {
        net.send.socket = 0
        net.send.buf_sz = strings.length(data)
        net.send.buf = data
        net.net_send()
    }

    sub get_host(uword name, ubyte size) {
        net.gethostbyname.buf = name
        net.gethostbyname.buf_sz = size
        net.net_gethostbyname()
    }

    sub go_back(bool reload) {
        ; first on the stack is self
        ; toss it because we are going back.
        if not reload
            void stack.pop()
        ; now we have our parent at top
        ; just peek it since it will be our current
        idx = stack.top()

        ; debug
        txt.nl()
;        txt.print("go_back stack idx: ")
;        txt.print_ubhex(idx, false)
;        txt.nl()
;        sys.wait(120)
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

        txt.column(4)
        for m in 1 to 35 {
            for n in 1 to 80 {
                char = input.next()
                when char {
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
            txt.column(4)
        }
        txt.nl()
        txt.column(4)
        txt.print("POS: ")
        txt.print_uwhex(input.pos, false)
        txt.nl()
        txt.column(4)
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
        txt.column(4)

        for m in 1 to 20 {
            for n in 1 to 20 {
                char = input.next()
                txt.print_ubhex(char, false)
                txt.chrout(' ')
            }
            txt.nl()
            txt.column(4)
        }
        txt.nl()
        txt.column(4)
        txt.print("POS: ")
        txt.print_uwhex(input.pos, false)
        txt.nl()
        txt.column(4)
        txt.print("CNT: ")
        txt.print_uwhex(input.cnt, false)
        input.pos = 0
    }

    sub getdata() {
        ; poll data loop (until server disconnects)
        main.poll_count = 0
        repeat {
            sys.set_irqd()
            net.net_poll()
            sys.clear_irqd()
            ;txt.print_uwhex(net.poll.socket[0], true)
            ;txt.nl()
            if (net.poll.socket[0] & net.SOCK_STAT_HAS_DATA) != 0 {
                ; socket has data!
                recv_data()
                txt.chrout('D')
                poll_count = 0
                continue
            } else {
                ; slight delay if no data
                sys.wait(10)
                ; count polls with no data
                poll_count++
                ; TODO: figure out best way to detect disconnect
                if poll_count > 6 {
                    send_byte($00)
                    txt.chrout('N')
                }
                ; something bad happened. timeout eventually
                if poll_count > 20
                    break
            }
            if poll_count > 7 {
                if (net.poll.socket[0] & net.SOCK_STAT_CONNECTED) == 0 {
                    txt.chrout('X')
                    close_socket()
                    break
                }
            }
        }
    }

}
