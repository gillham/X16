;
%output prg
%launcher basic
%zeropage basicsafe
%import diskio
%import strings
%import textio

main {
    uword memptr = memory("buffer", 16384, 256)
    uword count = 0
    str input = "."*30
    const ubyte bank_start = 32
    const ubyte bank_end = 63

    sub start() {
        ubyte i
        txt.nl()
        txt.print("enter the name of the file to upload: ")
        void txt.input_chars(input)
        txt.nl()

        if diskio.f_open(input) {
            for i in bank_start to bank_end {
                txt.print("bank: ")
                txt.print_ub(i)
                count = diskio.f_read(memptr, 16384)
                cx16.rombank(i)
                sys.memcopy(memptr, $c000, count)
                cx16.rombank(0)
                txt.print("...")
                txt.print_uw(count)
                txt.print("... done")
                txt.nl()
            }
        } else {
            txt.print("\nerror: failed to open file.\n")
        }
        diskio.f_close()
    }
}
