; prog8 options
%encoding iso
%zeropage basicsafe

; libraries
%import textio
%import libnet

main {
    uword buf = memory("receive", 1 * 256, 256)
    uword url = memory("url", 1 * 256, 256)
    ubyte key = 0

    uword count = 0

    sub start() {
        txt.iso()

        txt.print("What site? ")
        ubyte size = txt.input_chars(url)
        txt.nl()

        if net.load() {
            txt.print("Looking up site name...")
            txt.nl()
            get_host(url, size)
            txt.print("Opening socket...")
            txt.nl()
            open_socket(70)
            txt.print("Polling for socket open...")
            txt.nl()
            poll_open()
            txt.print("Starting poll loop...")
            txt.nl()

            ; send gopher request
            send_byte($0d)
            send_byte($0a)

            ; poll data loop?
            ubyte tick = 0
            ;sys.wait(1)
            repeat {
                sys.set_irqd()
                net.net_poll()
                sys.clear_irqd()

                ; check connected state first as
                ; socket status won't be valid
                ; after recv_data()
                if (net.poll.socket[0] & net.SOCK_STAT_CONNECTED) == 0 and (net.poll.socket[0] & net.SOCK_STAT_HAS_DATA) == 0{
                    txt.chrout('X')
                    break
                }
                if (net.poll.socket[0] & net.SOCK_STAT_HAS_DATA) != 0 {
                    ; socket has data!
                    recv_data()
                    txt.chrout('D')
                } else {
                    tick++
                    ;send_byte($00)
                    txt.chrout('N')
                    sys.wait(1)
                }
                ; get a key from keyboard...
                key = cbm.GETIN2()
                if key != 0 {
                    if key == $0d {
                        send_byte($0a)
                    } else {
                        send_byte(key)
                    }
                }
            }
        } else {
            txt.print("Load failed...")
            txt.nl()
        }
        txt.nl()
        txt.print("Bytes received: ")
        txt.print_uw(main.count)
        txt.nl()
    }

    sub close_socket() {
        net.close.socket = 0
        net.net_close()
    }

    sub open_socket(uword port) {
        ; IPv4
        net.open.ip_ty = net.IP_V4
        net.open.socket_arg0 = lsb(port)
        net.open.socket_arg1 = msb(port)
        net.open.socket = 0
        net.open.socket_ty = net.SOCK_TCP
        net.net_open()
    }

    sub poll_close() -> bool {
        ; poll for socket close
        ; return as soon as closed
        repeat 1 {
            sys.set_irqd()
            net.net_poll()
            sys.clear_irqd()
            if (net.poll.socket[0] & net.SOCK_STAT_CONNECTED) != 0
                return true
            ;sys.wait(10)
        }
        ; debug
        txt.chrout('.')
        return false
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

    sub recv_data() {
        ubyte i
        net.recv.socket = 0
        net.recv.buf_sz = 255
        net.recv.buf = buf
        sys.set_irqd()
        net.net_recv()
        sys.clear_irqd()
        if net.recv.recv_sz == 0 {
            return
        }
        main.count += net.recv.recv_sz
        txt.chrout('D')
    }

    sub send_byte(ubyte data) {
        net.send.socket = 0
        net.send.buf_sz = 1
        net.send.buf = &data
        net.net_send()
        txt.print("sent: ")
        ;txt.print_uwhex(net.send.sent_sz, false)
        txt.print_ubhex(data, false)
        txt.nl()
    }

    sub get_host(uword name, ubyte size) {
        net.gethostbyname.buf = name
        net.gethostbyname.buf_sz = size
        net.net_gethostbyname()
    }
}
