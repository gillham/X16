;
; $xx00 relocatable library
;

%memtop $FFFF
%address $1000
%output library
%zeropage dontuse

%import textio

main {
    ; This must be first in main!
    ; The compiler always generates the first slot in the jump
    ; table as main.start. Shown here (commented out) as a reminder.
    ;%jmptable(main.start)
    %jmptable(main.link, main.name, main.multiply)

    sub start() {
        txt.print("simple.lib start() called...\n")
    }

    ; copy link table from main prg
    sub link() {
        txt.print("hello from simple.lib link()...\n")
    }

    ; return the name of this library
    sub name() -> str {
        return("simple.lib")
    }

    ; call print_ub from main program
    sub multiply(ubyte i, ubyte j) -> ubyte {
        return i*j
    }
}
