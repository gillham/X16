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
PCCARGS=-asmlist -target cx16 -out build/

PROGS	= build/main.prg

all: build $(PROGS) copy

build:
	$(MD) build

build/%.prg : src/%.p8
	$(PCC) $(PCCARGS) $< 

clean:
	$(CLEAN)

copy: $(PROGS)
	@cp -p build/main.prg binary/cpuid
	
emu: all
	@echo ""
	x16emu $(EMUARGS) -fsroot build/
	@echo ""

run: all
	caly run --hard build/main.prg

#
# end-of-file
#
