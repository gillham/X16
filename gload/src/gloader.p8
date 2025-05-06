;
; This version loads & runs the Golden Loader
; from a file. Generally only useful for development.
;

%output prg
%launcher basic
%zeropage basicsafe
%import libgloader
%import textio

;
; This calls the loader and generally shouldn't return.
; If the loader.bin isn't found or has a read error it
; should fallback here and print an error message.
;
main {
    sub start() {

        ; use golden loader to load nonlinear file.
        txt.print("loading...\n")
        if not libgloader.load("loader.bin", "game.non", $0817) {
            txt.print("\nload failed\n")
            sys.exit(1)
        }
        txt.print("normally never reached...\n")
    }
}

