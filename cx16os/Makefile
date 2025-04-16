#
# Simple Makefile for a Prog8 program.
#

# Cross-platform removal command
ifeq ($(OS),Windows_NT)
    CLEAN = del /Q build\* 
    RM = del /Q
    MD = mkdir
else
    CLEAN = rm -f build/*
    RM = rm -f
    MD = mkdir -p
endif

EMUARGS=-debug -quality best -scale 2 -rtc -c816 -nvram nvram.bin
#EMUARGS=-ram 2048 -via2 -debug -quality best -scale 2 -rtc -c816 -nvram nvram.bin
PCC=prog8c
PCCARGS=-asmlist -target cx16os.properties -out build/
PCCARGS24K=-asmlist -target cx16os.24kb_properties -out build/

PROGS	= build/arch.prg build/hello.prg build/pwd.prg build/uname.prg

all: build $(PROGS) copy

build:
	$(MD) build

build/%.prg : src/%.p8
	$(PCC) $(PCCARGS) $< 

clean:
	$(CLEAN)

copy: $(PROGS)
	@cp -p build/arch.prg OS/bin/arch
	@cp -p build/hello.prg OS/bin/hello
	@cp -p build/pwd.prg OS/bin/pwd8
	@cp -p build/uname.prg OS/bin/uname
	
emu:
	@echo ""
	x16emu $(EMUARGS)
	@echo ""

run: all
	@echo ""
	x16emu $(EMUARGS) -fsroot OS/
	@echo ""

#
# end-of-file
#
