# CX16 OS app in Prog8


DEPRECATED: This has been moved to my [prog8targets repository](https://github.com/gillham/prog8targets) alonside several other custom targets.


Here some simple programs written for cx16os.  Including a minimal
cx16os "Hello World" written in Prog8.

The libraries/cx16os directory has syslib.p8, textio.p8, and similar libraries
for the custom target.  The custom target is defined in the cx16os.properties file.

## Building

A cx16os program is just straight code with no two byte load address.  It should
be assembled to $A300.  With the Prog8 compiler's external custom target support
you can use the compiler builds from the official repository.  Either the jar file
with `java -jar compiler.jar` or `prog8c` can be used to run the compiler.
To use the custom target you provide a properties file to the `-target` parameter
as shown below.

```bash
prog8c -target cx16os.properties hello.p8
```

To use the simple cx16os examples just run `make` and they will be in build/.
If you download the latest cx16os and unzip it here you will have an `OS` directory.
You can then do `make run` to launch the `x16emu` command to boot cx16os.

## Running examples

Included in the examples are `arch`, `hello`, `pwd` (called `pwd8` when run), and `uname`.
These are like their Linux/Unix counterparts except `hello` which just prints a "Hello World" style
message.

The `uname` command takes various arguments and prints information about the system.  Try `uname -a` to get all of the information available.

Arguments:
```
    -a all available info
    -b total banks / memory
    -i hardware platform
    -k kernal version
    -m architecture
    -o operating system
    -p architecture
    -r kernal version
    -s SMC version
    -v VERA version
```

## Developing with Prog8

[add details about building with Prog8]

