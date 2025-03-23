#
# Simple Makefile for a Prog8 program.
#

# Cross-platform removal command
ifeq ($(OS),Windows_NT)
    RM = del /Q
    MD = mkdir
else
    RM = rm -f
    MD = mkdir -p
endif

PCC=prog8c
PCCARGS=-asmlist -target cx16 -out build/

PROGS	= build/romload.prg

all: build $(PROGS) romfile

build:
	$(MD) build

build/romload.prg: src/romload.p8
	$(PCC) $(PCCARGS) $< 

build/%.prg : src/%.p8
	$(PCC) $(PCCARGS) $< 

romfile:
	cd build && ../bin/romfile.py

clean:
	$(RM) build/* romfile.bin

emu:
	@echo ""
	x16emu -debug -quality best -scale 2 -fsroot build/
	@echo ""

run:
	@echo ""
	x16emu -scale 2 -rtc -run -cartbin cartfile.bin -prg build/romload.prg -fsroot build/ -debug
	@echo ""

#
# end-of-file
#
