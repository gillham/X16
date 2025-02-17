;
; Client side linker / relocator
; Called by the library's load() function
;

lib {
    const ubyte JMP_SLOT0 = $00
    const ubyte RELOC_BYTE = JMP_SLOT0 + $02

    ; X16 relocatable loading.
    sub loadreloc(uword rl_buf, str rl_fname, ubyte rl_pages) -> bool {
        ubyte rl_adjust = 0
        uword i = 0
        bool rl_subtract = true

        uword endaddress = diskio.load_raw(rl_fname, rl_buf)
        if endaddress == 0 {
            return false
        }

        ; do relocation fixup..
        ubyte libpg = msb(rl_buf)
        ubyte reloc = @(rl_buf+RELOC_BYTE)
        ubyte reloc_min = reloc-1
        ubyte reloc_max = reloc+rl_pages

        if libpg > reloc {
            rl_subtract = false
            rl_adjust = libpg - reloc
        } else {
            rl_subtract = true
            rl_adjust = reloc - libpg
        }

        for i in 0 to rl_pages*256-1 {
            if rl_buf[i] > reloc_min and rl_buf[i] < reloc_max {
                if rl_subtract {
                    rl_buf[i] = rl_buf[i] - rl_adjust
                } else {
                    rl_buf[i] = rl_buf[i] + rl_adjust
                }
            }
        }

        ; call first function (start) in lib
        void call(rl_buf+JMP_SLOT0)

        return true
    }
}
