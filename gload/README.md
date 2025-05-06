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
directory.`  Then copy `gload.prg` and your `game.non` or equivalent to storage on
your Commander X16 and you should be set.  Running `gload.prg` should load & start
`game.non` or whatever you provided.

# Creating the nonlinear file

I have a couple of Python scripts for this that will be added soon.


# Usage

Put `gload.prg` and `game.non` in the same spot and run `gload.prg`.  Nothing to it.
You might want to rename the loader to `gload` or `MyGame` or `runme` etc.  Something
slightly better than `gload.prg`, but for testing this is great.


