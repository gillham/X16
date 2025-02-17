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
    %jmptable(main.link, main.myprint, main.myprint_ub, main.myprint_uw)

    sub start() {
        txt.print("test.lib start() called...\n")
    }

    ; copy link table from main prg
    sub link() {
        txt.print("hello from test.lib link()...\n")
    }

    ; just call print included in the lib
    sub myprint(str text) {
        txt.print(text)
    }

    ; just call print_ub included in the lib
    sub myprint_ub(ubyte value) {
        txt.print_ub(value)
    }

    ; just call print_uw included in the lib
    sub myprint_uw(uword value) {
        txt.print_uw(value)
    }
}
