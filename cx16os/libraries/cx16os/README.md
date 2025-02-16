# CX16 OS support for Prog8

## Prog8 system libraries

Currently copies of a few Commander X16 native libraries with very minor adjustments.
These will be slowly converted over to support cx16os.

Just minimal chrout / chrin support is working for cx16os.  That allows a lot of
the textio library to work, at least partially.

## "Includes" files

Currently just `os.p8` which defines various cx16os api calls as `extsub` stubs.
These will get arguments and return values added as the functions are used / needed.

## License

The original Prog8 license applies to the files that are modified copies from the official repository. Not `os.p8` which is created from cx16os documentation.
Essentially GPL v3, but I added the LICENSE file to this directory.

