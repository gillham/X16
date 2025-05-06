;
; $0400 Golden Loader
;

%memtop $07FF
%address $0400
%launcher none
%option no_sysinit
%output library
%zeropage dontuse

%import diskio  ; required
%import textio  ; for debug, maybe won't need (also size?)

;
main {
    %jmptable (
        ;main.start is here.
        main.gload_
    )

    sub start() {
        ; do nothing here?
        ; we need the filename
        ; passed so we are reusable
    }

    asmsub gload_(uword ptr @AY, uword entry @R0) -> bool @A{
        %asm {{
            sta p8b_main.p8s_gload.p8v_ptr
            sty p8b_main.p8s_gload.p8v_ptr+1
            lda cx16.r0L
            ldy cx16.r0H
            sta p8b_main.p8s_gload.p8v_entry
            sty p8b_main.p8s_gload.p8v_entry+1
            jmp p8b_main.p8s_gload
        }}
    }

    ; perform load based on filename
    ; passed from the main program.
    ; currently we just deal with a single filename.
    sub gload(uword ptr, uword entry) -> bool {
        txt.print("\nld: ")
        txt.print(ptr)
        txt.nl()

        if not diskio.f_open(ptr) {
            txt.chrout('X')
            txt.nl()
            return false
        }

        txt.print("\n  addr bytes")
        txt.nl()

        repeat {
            ; first we need to read 4 bytes.
            ; first two bytes are count
            ; next two bytes is load address
            ; so R14 has count, R15 load address
            cx16.r1 = diskio.f_read(&cx16.r14, 4)
            
            ; end of load marker is '00 00' bytes
            if cx16.r14 == 0 {
                txt.nl()
                goto entry
            }

            cx16.r1 = diskio.f_read(cx16.r15, cx16.r14)
            if cx16.r1 == 0 {
                txt.chrout('x')
                txt.nl()
                break
            }

            txt.chrout('l')
            txt.spc()
            txt.print_uwhex(cx16.r15, false)
            txt.spc()
            txt.print_uwhex(cx16.r14, false)
            txt.nl()
        }
        txt.chrout('f')
        txt.nl()

        ; Once we started loading we shouldn't return
        ; since we likely overwrote the code that called us.
        repeat {}
    }

}
