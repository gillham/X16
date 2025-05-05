;
; $A000 library
;

%memtop $BFFF
%address $A000
%launcher none
%option no_sysinit
%output library
%zeropage dontuse

;
; These are functions in the main prg used by the library
;
extern $A200 {
    lextern:
        %asm {{
            jmp $0000
            jmp $0000
            jmp $0000
        }}

    extsub $A200 = print(str text @AY) clobbers(A,Y)
    extsub $A203 = print_ub(ubyte value @ A) clobbers(A,X,Y)
    extsub $A206 = print_uw(uword value @ AY) clobbers(A,X,Y)
}

;
main {
    const uword exttable = $A200
    const ubyte exttable_size = 3
    %jmptable (
        ;main.start is here.
        main.link,
        main.print,
        main.print_ub,
        main.print_uw
    )

    sub start() {
        ;bind(entry)     ; make block stay in 
        bind(extern)    ; make block stay in 
        bind(main)      ; make block stay in 
    }

    ; dummy function
    sub bind(uword address) {
    }

    ; copy link table from main prg
    sub link(uword tableptr) {
        sys.memcopy(tableptr, exttable, exttable_size*3)
        extern.print("link() called...\n")
        extern.print("hello from the library...\n")
    }

    ; call print from main program
    sub print(str text) {
        extern.print(text)
    }

    ; call print_ub from main program
    sub print_ub(ubyte value) {
        extern.print_ub(value)
    }
    ; call print_uw from main program
    sub print_uw(uword value) {
        extern.print_uw(value)
    }
}
