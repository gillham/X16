# Relocatable libraries / objects

This demonstrates a simple technique from [C64 OS](https://c64os.com/post/relocatable_6502) for creating small relocatable binaries (or "libraries") for 6502 processors.

This implementation is in Prog8 for the Commander X16.

## Building the demo

### Linux or macOS

First you need to run `make` to build the example. This requires `make`, `prog8c`, and `python` to be in your path.
Then you can run `make emu` to launch the emulator using the Host FS.

### Windows
First you need to run `make -f Makefile.win` to build the example. This requires `make`, `prog8c`, and `python` to be in your path.

Then you can run `make -f Makefile.win emu` to launch the emulator using the Host FS.

## Running the demo

Run the emulator as above or copy the contents of the `build` directory to an SD card to use on real hardware.

From there you run `LOAD "MAIN.PRG"` and `RUN` like a normal program.

Here is a screenshot of loading / running: ![loading](images/loading.png)

Here is the output of the sample program: ![output](images/output.png)
