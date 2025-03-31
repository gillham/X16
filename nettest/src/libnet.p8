%import lib

net {
    %option ignore_unused

    const byte IP_V4 = 4
    const byte IP_V6 = 6

    const byte IP_PROTO_ICMP = 1

    const byte SOCK_RAW    = 0
    const byte SOCK_TCP    = 1
    const byte SOCK_DBG    = 2
    const byte SOCK_SERIAL = 3

    const byte SER_ARG0_BAUD_9600    = (0 << 0)
    const byte SER_ARG0_BAUD_19200   = (1 << 0)
    const byte SER_ARG0_BAUD_38400   = (2 << 0)
    const byte SER_ARG0_BAUD_57600   = (3 << 0)
    const byte SER_ARG0_BAUD_115200  = (4 << 0)
    const byte SER_ARG0_BAUD_230400  = (5 << 0)
    const byte SER_ARG0_BAUD_460800  = (6 << 0)
    const byte SER_ARG0_BAUD_921600  = (7 << 0)

    const byte SER_ARG0_FLOW_OFF      = (0 << 3)
    const byte SER_ARG0_FLOW_XON_XOFF = (1 << 3)
    const byte SER_ARG0_FLOW_RTS_CTS  = (2 << 3)

    const byte SER_ARG0_DATA_BITS_5   = (0 << 5)
    const byte SER_ARG0_DATA_BITS_6   = (1 << 5)
    const byte SER_ARG0_DATA_BITS_7   = (2 << 5)
    const byte SER_ARG0_DATS_BITS_8   = (3 << 5)

    const byte SER_ARG1_STOP_BITS_1   = (0 << 0)
    const byte SER_ARG1_STOP_BITS_1_5 = (1 << 0)
    const byte SER_ARG1_STOP_BITS_2   = (2 << 0)

    const byte SER_ARG1_PARITY_NONE   = (0 << 2)
    const byte SER_ARG1_PARITY_ODD    = (1 << 2)
    const byte SER_ARG1_PARITY_EVEN   = (2 << 2)

    const byte SOCK_STAT_HAS_DATA  = 1
    const byte SOCK_STAT_CONNECTED = 2

    ; SOCK_DBG data looks like:
    ; tag [1 byte]
    ; tag-specific data [some bytes]
    ; ...
    const byte DBG_TAG_STR	= 0
    ; tag-specific data:
    ; null-terminated ASCII string, newline is \n only

    const byte DBG_TAG_UINT8	= 2
    const byte DBG_TAG_UINT16	= 4
    const byte DBG_TAG_UINT32	= 6
    const byte DBG_BASE_HEX     = 0
    const byte DBG_BASE_DEC     = 1
    ; tag-specific data:
    ; base: hex (0), decimal (1), binary (2) [1 byte]
    ; integer [1, 2, or 4 bytes]

    const byte DBG_TAG_INT8     = 1
    const byte DBG_TAG_INT16    = 3
    const byte DBG_TAG_INT32    = 5
    ; tag-specific data:
    ; integer [1, 2, or 4 bytes]

    sub open() {
        &ubyte[16] ip = $0004
        &ubyte ip_ty = $0014
        &ubyte socket = $0015
        &ubyte socket_ty = $0016
        &ubyte socket_arg0 = $0017
        &ubyte socket_arg1 = $0018
        ; is this valid? (result code after open?) not in api.asm
        &ubyte res = $0004
    }
    extsub $a000 = net_open() clobbers(A, X, Y)

    sub close() {
        &ubyte socket = $0004
    }
    extsub $a003 = net_close() clobbers(A, X, Y)

    sub send() {
        &ubyte socket = $0004
        &uword buf_sz = $0005
        &uword buf = $0007

        &ubyte res = $0004
        &uword sent_sz = $0005
    }
    extsub $a006 = net_send() clobbers(A,X,Y)

    sub recv() {
        &ubyte socket = $0004
        &uword buf_sz = $0005
        &uword buf = $0007

        &ubyte res = $0004
        &ubyte recv_sz = $0005
    }
    extsub $a009 = net_recv() clobbers(A,X,Y)

    sub poll() {
        &ubyte[4] socket = $0004
    }
    extsub $a00c = net_poll() clobbers(A,X,Y)

    sub gethostbyname() {
        &uword buf = $0004
        &uword buf_sz = $0006
    }
    extsub $a00f = net_gethostbyname() clobbers(A,X,Y)

    ; use lib.loadbank() to load into $A000
    sub load() -> bool {
        bool result = lib.loadbank($a000, "net.bin", false)
        ; cleanup.
        return result
    }
}
