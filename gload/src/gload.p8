;
; Golden Loader loader.
; This program copies the Golden Loader to $0400.
; Then it calls the gload function with the filename
; and the entry point once loaded.
;

%output prg
%launcher basic
%zeropage basicsafe
%import libgload
%import textio

;
; This basically just calls libgload which
; has the Golden Loader embedded which it
; copies.  Normally the load call never
; returns.
;
main {
    sub start() {

        ; copy the golden loader to $0400
        txt.print("loading...\n")
        if not libgload.load("game.non", $0817) {
            txt.print("\nload failed\n")
            sys.exit(1)
        }
        txt.print("should never get here...\n")
    }
}

