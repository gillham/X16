%zeropage basicsafe
%import textio
%option no_sysinit

main {
    sub start() {
        txt.print("hello from a gloaded program!\n")
        repeat{}
    }
}
