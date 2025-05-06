%import lib
%import textio

libgloader {
    ; use lib.loadbank() to load into $0400
    sub load(str loader, str filename, uword entry) -> bool {
        bool result = lib.loadbank($0400, loader, true)

        ; initialize
        if result
            gload(filename, entry)

        ; cleanup.
        return result
    }

    ; $0400 is library start()
    extsub $0403 = gload(uword filename @ AY, uword entry @R0)

}

