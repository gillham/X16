#!/bin/sh

PCC="prog8c -asmlist -target cx16os.properties -out build/"
PCC24K="prog8c -asmlist -target cx16os.24kb_properties -out build/"

${PCC} hello.p8 || exit 1
${PCC} pwd.p8 || exit 1

cp -p build/hello.prg OS/bin/hello
cp -p build/pwd.prg OS/bin/pwd8

#
# end-of-file
#
