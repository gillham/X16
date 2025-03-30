; Prog8 options
%encoding iso
%zeropage basicsafe

%import strings

stack {
    const ubyte SIZE = 20
    const ubyte OFFSET_TYPE = 1
    const ubyte OFFSET_SELECTOR = OFFSET_TYPE 
    const ubyte OFFSET_SERVER = OFFSET_SELECTOR + 124
    const ubyte OFFSET_PORT = OFFSET_SERVER + 124

    uword buf = memory("stack", SIZE * 256, 256)  ; can go back 20 times
    ubyte ptr = 0

    ; return index of top of stack
    ; but don't adjust
    sub top() -> ubyte {
        return ptr
    }

    ; pop last reference
    ; provides index to use against buffer
    ; always returns 0 if stack is empty
    sub pop() -> ubyte {
        if ptr > 0
            defer ptr--
        return ptr
    }

    ; push reference to stack
    ; actually returns index to use against the buffer
    ; returns SIZE-1 if stack is full
    sub push() -> ubyte {
        if ptr < SIZE
            ptr++
        return ptr
    }

    sub set_type(ubyte index, ubyte type) {
        uword offset = index * 256
        buf[offset] = type
    }

    sub get_type(ubyte index) -> ubyte {
        uword offset = index * 256
        return buf[offset]
    }

    sub set_selector(ubyte index, uword selector) {
        uword offset = index * 256 + OFFSET_SELECTOR
        void strings.copy(selector, buf+offset)
    }

    sub get_selector(ubyte index) -> uword {
        uword offset = index * 256 + OFFSET_SELECTOR
        return buf + offset
    }

    sub set_server(ubyte index, uword server) {
        uword offset = index * 256 + OFFSET_SERVER
        void strings.copy(server, buf+offset)
    }

    sub get_server(ubyte index) -> uword {
        uword offset = index * 256 + OFFSET_SERVER
        return buf + offset
    }

    sub set_port(ubyte index, uword port) {
        uword offset = index * 256 + OFFSET_PORT
        void strings.copy(port, buf+offset)
    }

    sub get_port(ubyte index) -> uword {
        uword offset = index * 256 + OFFSET_PORT
        return buf + offset
    }

}
