# X16
Commander X16 related.

## cpuid

An attempt to identify an OtterX vs a Commander X16. Not working.

## gload

The Golden Loader, a demonstration of using 64tass' nonlinear mode to load large files.

## gopher

Early alpha version of a Gopher protocol client using the [Calypso](https://www.tindie.com/products/wavicle/calypso-multi-peripheral-for-x16-and-otterx/) networking peripheral
for the Commander X16 and OtterX.

## nettest

A simple tool to test TCP sockets by reading from a server.

## network

The start of a Prog8 networking library for the Calypso board.

## nk

Network Kompile allows sending source code from the Commander X16 or OtterX to a server
process in Python that will compile the source code and return the resulting binary.
Designed for Prog8 but can be used for other toolchains.

## nkd

The Python script backend for Network Kompile.  Aka Network Kompile Daemon (nkd).

## relocatex16

Example of a relocatable object with Prog8.  This novel relocation technique
based on the description from [Greg Nacu](https://c64os.com/post/relocatable_6502)
works for relocatable binaries between 1-8 pages.

## romload

Prog8 program to load rom banks 32-63 on a Commander X16.  Only useful
with a prototyping cartridge with RAM on it.  You can load a ROM file in
and reset the Commander X16 to simulate a true ROM cartridge.

## xlink

Technology demo in Prog8 of a simplistic technique to allow a loaded binary module to be
"linked" to in such a way that the loaded module can call functions in the main program
and vice versa.  So you can load a driver module that is able to print using txt.print()
from the main Prog8 program for example.  It helps save space.

## cx16os

DEPRECATED: This has been moved to my
[prog8targets repository](https://github.com/gillham/prog8targets)
alongside several other custom targets.

Simple test of compiling a cx16os program with Prog8.
Includes an external target file for Prog8.


