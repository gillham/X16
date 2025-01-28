;
; Normal main program
;

%output prg
%launcher basic
;%zeropage dontuse
%zeropage basicsafe

; Prog8 system libraries
%import diskio
%import textio

; local library
%import lib
%import libsimple
%import libtest

;
; 
;
main {
    sub start() {

        ; clear the screen to blue and set text to white
        txt.color2(1, 6)
        txt.clear_screen()
        txt.lowercase()

        ; 1st library
        void libtest.load()      ; link/init library.

        ; 2nd library
        void libsimple.load()    ; link/init 2nd library.

        tests()

        void libsimple.unload()  ; nop for now
        void libtest.unload()   ; nop for now
    }

    sub tests() {
        libtest.print("\ncalling test.lib.print_ub(7): ")
        libtest.print_ub(7)
        txt.nl()

        libtest.print("\ncalling test.lib.print_uw(16384): ")
        libtest.print_uw(16384)
        txt.nl()

        txt.print("\nprinting simple.lib name(): ")
        txt.print(libsimple.name())
        txt.nl()

        txt.print("\ncalling simple.lib multiply(6,8): ")
        txt.print_ub(libsimple.multiply(6, 8))
        txt.nl()
    }
}

