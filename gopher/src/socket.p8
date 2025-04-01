;
; Minimalist socket module
; Uses libnet which currently supports:
;   - Calypso SPI NIC via net.bin $a000 driver
;     (see: https://codeberg.org/smrobtzz/x16-esp-fw/src/branch/main/x16/net/net.p8 )
;
; Up to 4 sockets can be used in theory, but NOT YET.
; Only socket 0 is currently supported.
; Parameters are all in zero page, see libnet.p8 definitions.
;

%import strings
%import libnet

socket {
    %option ignore_unused
    ; Open socket to port based on
    ; ip address already configured in zero page.
    ; You must call gethostbyname() first.
    sub open(ubyte sock, uword port) {
        ; IPv4
        net.open.ip_ty = net.IP_V4
        net.open.socket_arg0 = lsb(port)
        net.open.socket_arg1 = msb(port)
        net.open.socket = sock
        net.open.socket_ty = net.SOCK_TCP
        net.net_open()
        ; return net.open.res?
    }

    ; Cleans up socket.
    sub close(ubyte sock) {
        net.close.socket = sock
        net.net_close()
    }

    ; Polls for socket open for 10 seconds
    ; returning as soon as connected.
    sub poll_open(ubyte sock) -> bool {
        repeat 60 {
            sys.set_irqd()
            net.net_poll()
            sys.clear_irqd()
            if (net.poll.socket[0] & net.SOCK_STAT_CONNECTED) as bool
                return true
            sys.wait(10) ; poll_open timeout/wait
        }
        return false
    }

    ;
    ; Reads directly into buf and returns size.
    ; buf_sz is allegedly a uword but fails with 256?
    ; TODO: leave as ubyte for now.
    ;
    sub recv(ubyte sock, ubyte size, uword buf) -> uword {
        net.recv.socket = sock
        net.recv.buf_sz = size
        net.recv.buf = buf
        sys.set_irqd()
        net.net_recv()
        sys.clear_irqd()
        return net.recv.recv_sz
    }

    ; sends a buffer and returns amount sent up to size
    ; TODO: limited to ubyte for the moment (needs testing)
    ; see recv() comment above
    sub send(ubyte sock, ubyte size, uword buf) -> uword {
        net.send.socket = sock
        net.send.buf_sz = size
        net.send.buf = buf
        net.net_send()
        return net.send.sent_sz
    }

    ; convenience, sends a single byte
    sub send_byte(ubyte sock, ubyte data) -> ubyte {
        net.send.socket = sock
        net.send.buf_sz = 1
        net.send.buf = &data
        net.net_send()
        return net.send.sent_sz as ubyte
    }

    ; convenience, sends a null terminated string
    sub send_string(ubyte sock, uword data) -> ubyte {
        net.send.socket = sock
        net.send.buf_sz = strings.length(data)
        net.send.buf = data
        net.net_send()
        return net.send.sent_sz as ubyte
    }

    ; lookup DNS or convert IP to bytes in zero page
    ; required before calling open()
    sub gethostbyname(uword name, ubyte size) {
        net.gethostbyname.buf = name
        net.gethostbyname.buf_sz = size
        net.net_gethostbyname()
    }
}
