# X16 Golden Loader

This just shows a way to use a loader in Commander X16 "Golden RAM" ($400-$7FF)
and 64tass nonlinear mode to load large files into main ram and banked ram from
a single file.  Well the loader is a separate file, but main ram & banked ram
is all in one file.

In `src/gload.p8` is a version that embeds the loader and would be typically
what you want.  The `src/gloader.p8` version loads `loader.bin` from storage
which is mostly useful during development and testing.

# Building

Currently this builds on macOS and Linux. It will be tested on Windows soon.

There are two parameters in `gload.p8` that should be edited.  One is the filename
and the second is the entry address for the loader to jump to. Those would be the
`game.non` and `$0817` values in the call to `libgload.load` below.

```prog8
if not libgload.load("game.non", $0817) {
    txt.print("\nload failed\n")
    sys.exit(1)
}
```

The entry address is likely to be `$0817` for a normal Prog8 compiled binary. You
can look in the assembly listing (-asmlist flag) and find it.
Here is an example:

```
.0817                   prog8_entrypoint
```

Once this matches what you need, just run `make` to build `gload.prg` in the `build/`
directory.  Then copy `gload.prg` and your `game.non` or equivalent to storage on
your Commander X16 and you should be set.  Running `gload.prg` should load & start
`game.non` or whatever you provided.

# Creating the nonlinear file

I have a couple of Python scripts for this that will be added soon.


# Usage

Put `gload.prg` and `game.non` in the same spot and run `gload.prg`.  Nothing to it.
You might want to rename the loader to `gload` or `MyGame` or `runme` etc.  Something
slightly better than `gload.prg`, but for testing this is great.


# Converting existing projects

If you're going to convert existing projects you'll need to remove any existing
load calls in the main program.  Since the Golden Loader will load everything you 
don't need the load calls and can comment them out.

Then you need to recompile your main program.  Since it doesn't do the loading anymore
it can't be run directly and needs to be package as a nonlinear file.

Here is an example using the zsmkit v2 demo that is included with the Prog8c compiler
source on GitHub.

These lines were commented out in the `demo.p8` source:
```prog8
;cx16.rambank(zsmkit.ZSMKitBank)
;void diskio.load_raw("zsmkit-a000.bin",$A000)
;cx16.rambank(2)
```

Then it was compiled with the usual `prog8c -target cx16 demo.p8`

Now you can convert the generated `demo.prg` to a nonlinear file.

```bash
bin/mknon.py -i zsm/demo.prg -o out/demo.non -u
```

This expects the demo files in `zsm/` and an output directory to exists as `out/`.

Now you need to generate a nonlinear file from the ZSMKit banked module.

```bash
bin/mknon.py -i zsm/ZSMKIT-A000.BIN -o out/zsmkit.non -b 1

INFO: generating banked nonlinear file.
INFO: bank: 1 offset: 0 end: 5369
```

Note the starting bank of 1 which is defined in the `zsmkit.p8` in the demo.

Now we need to convert the `MUSIC.ZSM` as well.

```bash
bin/mknon.py -i zsm/MUSIC.ZSM -o out/music.non -b 2

INFO: generating banked nonlinear file.
INFO: bank: 2 offset: 0 end: 8192
INFO: bank: 3 offset: 8192 end: 16384
INFO: bank: 4 offset: 16384 end: 24576
INFO: bank: 5 offset: 24576 end: 32768
INFO: bank: 6 offset: 32768 end: 40960
INFO: bank: 7 offset: 40960 end: 49152
INFO: bank: 8 offset: 49152 end: 57344
INFO: bank: 9 offset: 57344 end: 65536
INFO: bank: 10 offset: 65536 end: 73728
INFO: bank: 11 offset: 73728 end: 81920
INFO: bank: 12 offset: 81920 end: 90112
INFO: bank: 13 offset: 90112 end: 98304
INFO: bank: 14 offset: 98304 end: 106496
INFO: bank: 15 offset: 106496 end: 112583
```

This starts at bank 2 (ZSMKit will be in bank 1) and `mknon.py` shows
some information about the banks used.

Finally we want to combine the 3 different nonlinear files into one larger one
that we can load with the Golden Loader.  Note that the individual files we
generated above are nonlinear files and can be loaded by the Golden Loader, but
in this case we need all three of these files together to be useful.

Here are combine these all into `demo/game.non` and it is ready to use.

```prog8
bin/nonlink.py -o demo/game.non out/demo.non out/zsmkit.non out/music.non
```

Now you could type `make run` and `x16emu` should launch with the fsroot set to
the demo directory.  `^gload` should launch it.

Find me on Discord if you have questions.
