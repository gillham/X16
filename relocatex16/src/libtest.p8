;
; Client side linkage for a small shared module
;

libtest {
    ; library size in pages
    const ubyte size = 2
    str library = "test.lib.r"
    uword libbuf = memory("libtest", size * 256, 256)

    ; byte offset from library load address
    ; aka slot in jump table (this is not the fixup location)
    const uword lib_table = $00
    const uword start_      = lib_table + 0 * 3 ; $xx00
    const uword link_       = lib_table + 1 * 3 ; $xx03
    const uword print_      = lib_table + 2 * 3 ; $xx06
    const uword print_ub_   = lib_table + 3 * 3 ; $xx09
    const uword print_uw_   = lib_table + 4 * 3 ; $xx0c

    ; unload (free) resources from load
    ; (only if allocated somehow)
    sub unload() -> bool {
        return true
    }

    ; simplified to use lib.loadreloc()
    sub load() -> bool {
        ubyte libpg = msb(libbuf)
        bool result = lib.loadreloc(libbuf, library, size)

        ; do actual fixup

        @(&link+2) = libpg
        @(&print+2) = libpg
        @(&print_ub+2) = libpg
        @(&print_uw+2) = libpg

        link(libbuf)

        return result
    }

    ; stub for relocatable library test.lib.r link()
    asmsub link(uword arg0 @AY) clobbers(A,X,Y){
        %asm {{
            jmp p8b_libtest.p8c_link_
        }}
    }

    ; stub for relocatable library test.lib.r print()
    asmsub print(str arg0 @AY) {
        %asm {{
            jmp p8b_libtest.p8c_print_
        }}
    }

    ; stub for relocatable library test.lib.r print_ub()
    asmsub print_ub(ubyte arg0 @A) {
        %asm {{
            jmp p8b_libtest.p8c_print_ub_
        }}
    }

    ; stub for relocatable library test.lib.r print_uw()
    asmsub print_uw(uword arg0 @AY) {
        %asm {{
            jmp p8b_libtest.p8c_print_uw_
        }}
    }
}
