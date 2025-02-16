# CX16 OS app in Prog8

Here is a minimal CX16 OS "Hello World" written in Prog8.

The libraries/cx16os directory has syslib.p8, textio.p8, and similar libraries
for the custom target.  The custom target is defined in the cx16os.properties file.

## Building

A CX16 OS program is just straight code with no two byte load address.  It should
be assembled to $A300.  With the Prog8 compiler's external custom target support
you can use the compiler builds from the official repository.  Either the jar file
with `java -jar compiler.jar` or `prog8c` can be used to run the compiler.
To use the custom target you provide a properties file to the `-target` parameter
as shown below.

```bash
prog8c -target cx16os.properties hello.p8
```

## Developing with Prog8

[add details about building with Prog8]

