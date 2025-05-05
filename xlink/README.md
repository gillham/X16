# Cross linking

This just shows a way to share routines in a Prog8 main program with
a library loaded into a bank at $a000.

A jump table is created in a library normally to access its functions.  In this
demo a jump table is also created in the main program and copied into the
library for its use.

