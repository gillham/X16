;
; This module copies the embedded Golden Loader
; to $0400 and then asks it to load the file.
;
%import textio

libgload {
    ; $0400 is library start()
    extsub $0400 = gstart()
    extsub $0403 = gload(uword filename @ AY, uword entry @R0)

    ; use lib.loadbank() to load into $0400
    sub load(str filename, uword entry) -> bool {
        ;bool result = lib.loadbank($0400, loader, true)
        uword size = &loader_after - &loader_before
        txt.print("\ncopying ")
        txt.print_uw(size)
        txt.print(" bytes.\n")
        sys.memset($0400, $0400, $00)
        sys.memcopy(&loader_before, $0400, size)

        ; call loader start() to initialize variables
        gstart()

        txt.print("\ncalling gload: ")
        txt.print(filename)
        txt.spc()
        txt.print_uwhex(entry, true)
        txt.nl()
        ; initialize
        gload(filename, entry)

        ; the gload call above shouldn't return
        ; signal an error if it does
        return false
    }

    %align $10
    loader_before:
    %asmbinary "build/loader.bin"
    loader_after:
}

