#
# Simple Makefile for a Prog8 program.
#
#

# Cross-platform commands
ifeq ($(OS),Windows_NT)
    CLEAN = del /Q build\* 
    CP = copy
    RM = del /Q
    MD = mkdir
else
    CLEAN = rm -f build/*
    CP = cp -p
    RM = rm -f
    MD = mkdir -p
endif

PCC=prog8c
PCCARGS=-asmlist -target cx16 -out build/

PROGS	= build/loader.bin build/gload.prg build/gloader.prg build/demo.prg

all: build copy $(PROGS) build/demo.non emu

build/demo.prg: src/demo.p8
	$(PCC) $(PCCARGS) $<

build/demo.non: build/demo.prg
	python bin/mknon.py -u -i $< -o $@

build/loader.bin: src/loader.p8
	$(PCC) $(PCCARGS) $<

build/gload.prg: src/gload.p8 src/libgload.p8 src/lib.p8
	$(PCC) $(PCCARGS) $<

build/gloader.prg: src/gloader.p8 src/libgloader.p8
	$(PCC) $(PCCARGS) $<

build:
	$(MD) build

clean:
	$(RM) build/*

copy:
	$(CP) demo/game.non build/

emu:
	@echo ""
	x16emu -debug -nvram nvram.bin -quality best -scale 2 -fsroot build/
	@echo ""

run:
	x16emu -debug -nvram nvram.bin -quality best -scale 2 -fsroot demo/

#
# end-of-file
#
