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

PCC=prog8c
PCCARGS=-asmlist -target cx16 -out build/

PROGS	= build/main.prg

all: build $(PROGS)

build:
	$(MD) build

build/main.prg: src/main.p8 src/libnet.p8 src/lib.p8 src/gopher.p8 src/input.p8 src/stack.p8 src/socket.p8 src/term.p8
	$(PCC) $(PCCARGS) $< 

build/%.prg : src/%.p8
	$(PCC) $(PCCARGS) $< 

clean:
	$(CLEAN)
	cp net_emu.bin build/net.bin

emu:
	@echo ""
	x16emu -debug -quality best -scale 1 -nvram build/nvram.bin -fsroot build/
	@echo ""

run:	$(PROGS)
	caly run --hard build/main.prg
#	@echo ""
#	x16emu -scale 2 -rtc -run -cartbin cartfile.bin -prg build/romload.prg -fsroot build/ -debug
#	@echo ""

#
# end-of-file
#
