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

    sub start() {
        txt.iso()

        txt.print("What site? ")
        ubyte size = txt.input_chars(url)
        txt.nl()

        if net.load() {
            txt.print("Looking up site name...")
            txt.nl()
            get_host(size)
            txt.print("Opening socket...")
            txt.nl()
            open_socket()
            txt.print("Polling for socket open...")
            txt.nl()
            poll_open()
            txt.print("Starting poll loop...")
            txt.nl()

            ; poll data loop?
            while true {
                sys.set_irqd()
                net.net_poll()
                sys.clear_irqd()
                if (net.poll.socket[0] & net.SOCK_STAT_HAS_DATA) != 0 {
                    ; socket has data!
                    recv_data()
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
    }

    sub open_socket() {
        ; IPv4
        net.open.ip_ty = net.IP_V4
        ; special 127.127.127.1 ip
        ;net.open.ip[0] = 127
        ;net.open.ip[1] = 0
        ;net.open.ip[2] = 0
        ;net.open.ip[3] = 1
;        net.open.ip[0] = 192
;        net.open.ip[1] = 168
;        net.open.ip[2] = 70
;        net.open.ip[3] = 10
        ; gopher port 70
        net.open.socket_arg0 = 70
        net.open.socket_arg1 = 0
        ; telnet port 23
        ;net.open.socket_arg0 = 23
        ;net.open.socket_arg1 = 0
;        net.open.socket_arg0 = $d2
;        net.open.socket_arg1 = $04
        ; socket = 0?
        net.open.socket = 0
        ; tcp socket
        net.open.socket_ty = net.SOCK_TCP
        net.net_open()
    }

    sub poll_open() {
        do {
            net.net_poll()
        } until net.poll.socket[0] & net.SOCK_STAT_CONNECTED
    }

    sub recv_data() {
        ubyte i
        net.recv.socket = 0
        net.recv.buf_sz = 32
        net.recv.buf = buf
        sys.set_irqd()
        net.net_recv()
        sys.clear_irqd()
        if net.recv.recv_sz == 0 {
            return
        }
        for i in 0 to net.recv.recv_sz {
            if buf[i] == $0a {
                txt.chrout($0d)
            } else {
                txt.chrout(buf[i])
            }
            ;txt.chrout(buf[i])
            ;txt.print_ubhex(buf[i], false)
            ;txt.chrout(' ')
        }
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

    sub get_host(ubyte size) {
        net.gethostbyname.buf = main.url
        net.gethostbyname.buf_sz = size
        net.net_gethostbyname()
    }
}
