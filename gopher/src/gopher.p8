;
; Handles the tokenizing.
;

;%option no_symbol_prefixing
;%option ignore_unused
;%option force_output
%encoding iso

%import socket

gopher {
    ubyte selected_line = 0
    ubyte new_line = 0

    const ubyte MAX_LINES = 250

    ; make 1 larger than MAX_LINES to
    ; have a temporary spot for back requests
    ; type array only needs to be a byte
    ubyte[MAX_LINES+1] types 
    ; these will be pointers into input.buf
    uword[MAX_LINES+1] displays 
    uword[MAX_LINES+1] selectors 
    uword[MAX_LINES+1] servers 
    uword[MAX_LINES+1] ports 
    ; Gopher+ capable array only needs to be a byte
    ubyte[MAX_LINES+1] plus 

    ; number of lines from this request
    ubyte lines = 0

    ubyte char = 0
    ;ubyte type = 0

    ; Gopher protocol related
    const ubyte TCP_PORT = 70

    ; RFC1436
    const ubyte TYPE_FILE = '0'
    const ubyte TYPE_DIRECTORY = '1'
    const ubyte TYPE_PHONEBOOK = '2'
    const ubyte TYPE_ERROR = '3'
    const ubyte TYPE_BINHEX = '4'
    const ubyte TYPE_DOSBIN = '5'
    const ubyte TYPE_UUENCODED = '6'
    const ubyte TYPE_SEARCH = '7'
    const ubyte TYPE_TELNET = '8'
    const ubyte TYPE_BINARY = '9'
    const ubyte TYPE_REDUNDANT = '+'
    const ubyte TYPE_TN3270 = 'T'
    const ubyte TYPE_GIF = 'g'
    const ubyte TYPE_IMAGE = 'I'

    ; gopher+
    const ubyte TYPE_BITMAP = ':'
    const ubyte TYPE_MOVIE = ';'
    const ubyte TYPE_SOUND = '<'

    ; de facto
    const ubyte TYPE_DOC = 'd'
    const ubyte TYPE_HTML = 'h'
    const ubyte TYPE_INFO = 'i'
    const ubyte TYPE_PNG = 'p'
    const ubyte TYPE_RTF = 'r'
    const ubyte TYPE_WAVE = 's'
    const ubyte TYPE_PDF = 'P'
    const ubyte TYPE_XML = 'X'

    ; Reads the next line and parses it.
    sub read_line() {

        ; increment count when we return
        defer lines++

        types[lines] = input.next()

        if types[lines] == TYPE_INFO {
            gopher_info()
            ; the whole line including crlf was processed
            return
        }

        ; save user display string
        ; save pointer to string in array ?&?
        displays[lines] = input.buf + input.pos
        do {
            void input.next()
        } until input.peekc() == $09 or input.eof()

        ; input.pos points to tab character
        ; replace tab to null terminate string
        input.buf[input.pos] = $00
        ; advance over null
        void input.next()

        ; save server selector string
        selectors[lines] = input.buf + input.pos
        do {
            void input.next()
        } until input.peekc() == $09 or input.eof()

        ; input.pos points to tab character
        ; replace tab to null terminate string
        input.buf[input.pos] = $00
        ; advance over null
        void input.next()

        ; save server name
        servers[lines] = input.buf + input.pos
        do {
            void input.next()
        } until input.peekc() == $09 or input.eof()

        ; input.pos points to tab character
        ; replace tab to null terminate string
        input.buf[input.pos] = $00
        ; advance over null
        void input.next()

        ; save server port
        ports[lines] = input.buf + input.pos
        do {
            void input.next()
        } until input.peekc() == $09 or input.peekc() == $0d or input.eof()

        ; input.pos points to tab character
        ; replace tab to null terminate string saving char first (for crlf check)
        char = input.peekc()
        input.buf[input.pos] = $00
        ; advance over null
        void input.next()

        ; if we hit end of line after port
        ; eat crlf and return
        if char == $0d and input.peekc() == $0a {
            void input.next()
            ;txt.print("hit the check")
            txt.nl()
            return
        }

        ; check for gopher+ and eat the rest.
        do {
            char = input.next()
            if char == '+' {
                plus[lines] = true as ubyte
            }
            if input.eof()
                break
        } until char == $0d and input.peekc() == $0a

        ; eat the $0a, should be at next line now
        void input.next()
        return

    }

    ; handle special "info" line
    sub gopher_info() {
        ; show user display string only
        displays[lines] = input.buf + input.pos

        ; "fake" lines have immediate tab after type (empty user display)
        ; null terminate immediately and skip over it
        if input.peekc() == $09 {
            input.buf[input.pos] = $00
            void input.next()
        }

        do {
            void input.next()
        } until input.peekc() == $09 or input.peekc() == $0a or input.eof()

        ; input.pos points to tab character
        ; replace tab to null terminate string
        char = input.peekc()
        input.buf[input.pos] = $00
        ; advance over null
        void input.next()

        ; eat the rest of the line
        do {
            char = input.next()
            if input.eof()
                break
        } until char == $0d and input.peekc() == $0a

        ; eat the $0a, should be at next line now
        void input.next()
        return
    }

    ; select items in the menu
    sub menu() -> ubyte {
        repeat {
            if cbm.STOP2()
                return 0

            ubyte key = cbm.GETIN2()
            when key {
                3, 27           -> return main.G_EXIT      ; STOP and ESC  aborts
                'd'             -> {
                    main.dumpbuffer()
                    void txt.waitkey()
                    term.clear()
                    menudraw()
                }
                'D'             -> {
                    main.dumpbufferhex()
                    void txt.waitkey()
                    term.clear()
                    menudraw()
                }
                's'             -> {
                    txt.row(40)
                    txt.column(4)
                    txt.print_uwhex(stack.top(), false)
                    txt.spc()
                    txt.print_uwhex(stack.top(), false)
                    txt.spc()
                    txt.nl()
                }
                '\r','\n',' ','l',29   -> return selected_line ; load this line
                'b','h',157     -> {
                    ; go back
                    return main.G_BACK
                }
                'j',17 -> {     ; down
                    new_line = selected_line + 1
                    while new_line <= lines-1 and types[new_line] == TYPE_INFO {
                        new_line++
                    }
                    if new_line <= lines-1 and types[new_line] != TYPE_INFO {
                        unselect_line(selected_line)
                        selected_line = new_line
                        select_line(selected_line)
                    }
                }
                'k',145 -> {    ; up
                    new_line = selected_line - 1
                    while new_line > 0 and types[new_line] == TYPE_INFO {
                        new_line--
                    }
                    if new_line >= 0 and types[new_line] != TYPE_INFO {
                        unselect_line(selected_line)
                        selected_line = new_line
                        select_line(selected_line)
                    }
                }
                'r'     -> {
                    ; reload feature
                    ; reload current location
                    return main.G_RELOAD
                }
            }
        }
    }

    sub menudraw() {
        ubyte i

        ; mark first valid line as selected
        for i in 0 to gopher.lines-1 {
            if gopher.types[i] != gopher.TYPE_INFO {
                selected_line = i
                break
            }
        }

        ; print menu
        for i in 0 to gopher.lines-1 {
            if gopher.types[i] != gopher.TYPE_INFO {
                txt.chrout(' ')
                txt.chrout('[')
                txt.print_ub(i+1)
                txt.chrout(']')
            }
            txt.column(6)
            txt.print(gopher.displays[i])

            when gopher.types[i] {
                gopher.TYPE_DIRECTORY -> txt.chrout('/')

            }
            txt.nl()
        }

    }

    ; make actual gopher request
    sub request(uword selector, uword site, ubyte size, uword port) -> bool {
        socket.gethostbyname(site, size)
        socket.open(0, port)

        if not socket.poll_open(0) {
            return false
        }

        ; send gopher request
        void socket.send_string(0, selector)
        void socket.send_byte(0, $0d)
        void socket.send_byte(0, $0a)

        ; something worked... :)
        return true
    }

    sub handler(ubyte choice) -> ubyte {
        ; do something with current line
        when types[choice] {
            TYPE_DIRECTORY -> {
                if gopher.getmenu(choice) != 0 {
                    term.statusline.print("ERROR retrieving menu")
                    ;hack
                    ;gopher.lines = 0
                }
            }
            TYPE_FILE -> {
                if getfile(choice) !=0 {
                    term.statusline.print("ERROR retrieving file")
                    ;txt.print("ERROR retrieving file")
                    ;txt.nl()
                } else {
                    ; view text file..
                    term.clear()
                    showtext()
                }

            }

        }

        term.statusline.print("handler exit")
;        if gopher.lines == 0 {
;            txt.print("ERROR retrieving")
;            txt.nl()
;        }
        return 0
    }

    sub getfile(ubyte choice) -> ubyte {
        if types[choice] != TYPE_FILE
            return 1

        ; XXX: TODO: This should use a different buffer?
        ; reset input buffer
        input.pos = 0
        input.cnt = 0

        ; make new request
        void request(selectors[choice], servers[choice], strings.length(servers[choice]), conv.str2uword(ports[choice]))
        ; receive new data
        main.getdata()

        ; debug
;        txt.nl()
;        txt.print("   getfile POS: ")
;        txt.print_uwhex(input.pos, false)
;        txt.nl()
;        txt.print("   getfile CNT: ")
;        txt.print_uwhex(input.cnt, false)
;        txt.nl()

        ; make sure we have some data
        if input.eof()
            return 1

        return 0
    }


    sub getmenu(ubyte choice) -> ubyte {
        if types[choice] != TYPE_DIRECTORY
            return 1

        ; reset input buffer
        input.pos = 0
        input.cnt = 0
        ; reset state
        selected_line = 0
        new_line = 0
        lines = 0
        char = 0

        ; make new request
        void request(selectors[choice], servers[choice], strings.length(servers[choice]), conv.str2uword(ports[choice]))
        ; receive new data
        main.getdata()

        ; make sure we have some data
        if input.eof()
            return 1

        ; parse the data (only for TYPE_DIRECTORY)
        do {
            read_line()
        } until input.eof()
        return 0
    }

    ; show text files in input.buf
    sub showtext() {
        ubyte count=0
        while not input.eof() {
            char = input.next()
            if char == $0a {
                txt.nl()
                count++
                if count > term.screen_height-4 {
                    txt.nl()
                    txt.print(" -= Press a key =- ")
                    void txt.waitkey()
                    count = 0
                }
                continue
            }
            txt.chrout(char)
        }
        txt.nl()
        txt.print(" -= Press a key to return to menu =- ")
        void txt.waitkey()
        term.clear()
    }


    sub select_line(ubyte line) {
        line_color(line, term.colors_selected)
    }

    sub unselect_line(ubyte line) {
        line_color(line, term.colors_normal)
    }

    const ubyte dialog_topy = 1
    const ubyte dialog_topx = 5
    sub line_color(ubyte line, ubyte colors) {
        cx16.r1L = dialog_topy+line
        ubyte charpos
        for charpos in dialog_topx+1 to dialog_topx+68 {
            txt.setclr(charpos, cx16.r1L, colors)
        }
    }
}
