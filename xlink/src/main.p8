;
; Normal main program
;

%output prg
%launcher basic
%zeropage basicsafe
%import libbank
%import textio

;
; 
;
main {
    sub start() {

        ; load library to $a000
        txt.print("loading library...\n")
        if libbank.load() {
            txt.print("calling libbank.print...\n")
            libbank.print("test from the main program")
            txt.nl()
            libbank.print_ub(15)
            txt.print("\n")
            libbank.print_uw(16384)
        } else {
            txt.print("\nload failed\n")
            sys.exit(1)
        }
    }
}

