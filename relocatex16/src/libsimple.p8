;
; Client side linkage for a small shared module
;

libsimple {
    ; library size in pages
    const ubyte size = 1
    str library = "simple.lib.r"
    uword libbuf = memory("libsimple", size * 256, 256)

    ; byte offset from library load address
    ; aka slot in jump table (this is not the fixup location)
    const uword lib_table = $00
    const uword start_      = lib_table + 0 * 3 ; $xx00
    const uword link_       = lib_table + 1 * 3 ; $xx03
    const uword name_       = lib_table + 2 * 3 ; $xx06
    const uword multiply_   = lib_table + 3 * 3 ; $xx09

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
        @(&name+2) = libpg
        @(&multiply+2) = libpg

        ; make link call with a test pointer.
        link(libbuf)

        return result
    }

    ; stub for relocatable library test.lib.r link()
    asmsub link(uword arg0 @AY) {
        %asm {{
            jmp p8b_libsimple.p8c_link_
        }}
    }

    ; stub for relocatable library simple.lib.r name()
    asmsub name() -> str @AY {
        %asm {{
            jmp p8b_libsimple.p8c_name_
        }}
    }

    ; stub for relocatable library test.lib.r print_ub()
    asmsub multiply(ubyte arg0 @A, ubyte arg1 @Y) -> ubyte @A {
        %asm {{
            jmp p8b_libsimple.p8c_multiply_
        }}
    }
}
