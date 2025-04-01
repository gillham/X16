;
; Handles the input stream.
;

%encoding iso

input {
    %option ignore_unused
    uword buf = memory("inputbuf", 20000, 256)
    uword @nozp pos = $0000
    uword @nozp cnt = $0000

    ; preserve for error messages?
    ubyte col = 0
    uword line = 1

    ; returns true if we have no more input
    sub eof() -> bool {
        return pos >= cnt
    }

    ; returns the next value and moves the pointer
    sub next() -> ubyte {
        ; keep track of line number and column.
        ; for error messages
        if buf[pos] == $0a {
            col = 0
            line += 1
        } else {
            col += 1
        }

        defer pos += 1
        return buf[pos]
    }

    ; add byte to buffer
    sub add(ubyte data) {
        buf[cnt] = data
        cnt++
    }

    ; returns the next value without consuming it
    sub peekc() -> ubyte {
        return buf[pos]
    }


    ; reads user provided filename into input.buf
    ; returns the number of bytes read.
    ; returns zero if f_open or f_read_all fails.
    sub read_file(str filename) -> uword {
        cnt = 0
        txt.nl()
        txt.print("Reading: ")
        txt.print(filename)
        if diskio.f_open(filename) {
            ; need to add error checking here
            cnt = diskio.f_read_all(buf)
            txt.print(" (")
            txt.print_uw(cnt)
            txt.print(" bytes)")
            txt.nl()
        } else {
            txt.print("\nERROR: failed to open file.\n")
        }
        diskio.f_close()
        return cnt
    }
}
