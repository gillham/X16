#
# Simple Makefile for a Prog8 program.
#

# Cross-platform removal command
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

PROGS	= build/main.prg

all: build net $(PROGS) release

build:
	$(MD) build

net:
	$(CP) net_emu.bin build/net.bin

release:
	$(CP) build/main.prg binary/nk

build/main.prg: src/main.p8 src/libnet.p8 src/lib.p8 src/socket.p8
	$(PCC) $(PCCARGS) $< 

build/%.prg : src/%.p8
	$(PCC) $(PCCARGS) $< 

clean:
	$(CLEAN)

copy:
	caly upload binary/nk

emu:
	@echo ""
	x16emu -debug -quality best -scale 1 -nvram build/nvram.bin -fsroot build/
	@echo ""

run:	$(PROGS)
	caly run --hard build/main.prg

#
# end-of-file
#
