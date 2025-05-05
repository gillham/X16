%import lib
%import textio

libbank {
    ; use lib.loadbank() to load into $A000
    sub load() -> bool {
        bool result = lib.loadbank($a000, "banklib.bin", true)

        ; initialize
        if result
            link(exttable)

        ; cleanup.
        return result
    }

    ; $A000 is library start()
    extsub $A003 = link(uword address @ AY)
    extsub $A006 = print(str text @ AY)
    extsub $A009 = print_ub(ubyte value @ A)
    extsub $A00c = print_uw(uword value @ AY)

}

    ;
    ; This table can be anywhere in the main program.
    ;
exttable {
    %jmptable (
        txt.print,
        txt.print_ub,
        txt.print_uw
    )
}

