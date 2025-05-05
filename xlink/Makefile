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
PCCARGS=-noopt -asmlist -target cx16 -out build/

PROGS	= banklib.prg main.prg

all: build $(PROGS) emu

banklib.prg: src/banklib.p8
	$(PCC) $(PCCARGS) $<

main.prg: src/main.p8 src/libbank.p8 src/lib.p8
	$(PCC) $(PCCARGS) $<

build:
	$(MD) build

clean:
	$(RM) build/*

emu:
	@echo ""
	x16emu -quality best -scale 2 -fsroot build/
	@echo ""

#
# end-of-file
#
