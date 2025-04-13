; Prog8 options
%encoding iso
%zeropage basicsafe
%option no_sysinit

; Prog8 libraries
%import conv
%import strings
%import textio

term {
    ; colors for gopher UI
    const ubyte colors_normal = $b3
    const ubyte colors_selected = $d0
    ubyte[4] twiddlechars = ['|', '/', '-', $5c]

    ubyte screen_height
    ubyte screen_mode
    ubyte screen_width
    ubyte status_row
    ubyte save_col
    ubyte save_row
    ubyte twiddlecount
    str status = " " * 79

    sub init() {
        screen_mode, screen_width, screen_height = cx16.get_screen_mode()

        ; status line is the bottom row of the screen
        status_row = screen_height - 1
        ; make this one above the bottom during testing
        ;status_row = screen_height - 2

        ; init screen/colors
        ;cx16.set_screen_mode(0)
        ;cx16.set_screen_mode(8)
        txt.lowercase()
        txt.iso()
        txt.color2(colors_normal & 15, colors_normal>>4)

        term.clear()

        ; debug
        txt.column(5)
        txt.print("Screen width: ")
        txt.print_ub(screen_width)
        txt.nl()
        txt.column(5)
        txt.print("Screen height: ")
        txt.print_ub(screen_height)
        txt.nl()
    }

    ; clears screen and redraws status line
    sub clear() {
        txt.clear_screen()
        statusline()
    }

    ; restores rc position
    sub restore() {
        txt.plot(save_col, save_row)
    }

    ; saves rc position
    sub save() {
        save_col = txt.get_column()
        save_row = txt.get_row()
    }

    ; draws the status line at the bottom
    sub statusline() {
        save()
        txt.column(0)
        txt.row(term.status_row)
        txt.print(term.status)
        restore()

        sub chrout(ubyte char, ubyte pos) {
            save()
            txt.column(pos)
            txt.chrout(char)
            restore()
        }

        sub print(str msg) {
            status = msg
            statusline()
        }

        sub twiddle() {
            status[2] = twiddlechars[twiddlecount % 4]
            twiddlecount++
            statusline()
        }
        sub twiddleoff() {
            status[2] = ' '
            twiddlecount=0
            statusline()
        }
    }

}

