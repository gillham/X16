#
# Simple Makefile for a Prog8 program.
#

PCC=prog8c
PCCARGS=-asmlist -target cx16 -out build/

PROGS	= build/simple.lib.r build/test.lib.r build/main.prg

all: build $(PROGS) relcheck

build:
	mkdir -p build

build/main.prg: src/main.p8 src/lib.p8 src/libsimple.p8 src/libtest.p8
	$(PCC) $(PCCARGS) $< 

build/%.prg : src/%.p8
	$(PCC) $(PCCARGS) $< 

src/%_reloc.p8: src/%.p8 build/%.prg
	bin/reloc8 -v build/$(basename $(notdir $<)).bin -a $<

build/%.r : src/%_reloc.p8
	$(PCC) $(PCCARGS) $< 
	cp -p build/$(basename $(notdir $<)).bin $@

relcheck: build/simple.lib.r build/test.lib.r
	bin/relcheck build/simple.lib.r --asmlist build/simple.lib_reloc.list --library src/libsimple.p8
	bin/relcheck build/test.lib.r --asmlist build/test.lib_reloc.list --library src/libtest.p8
clean:
	rm -f build/*

emu:
	@echo ""
	x16emu -debug -quality best -scale 2 -fsroot build/
	@echo ""

#
# end-of-file
#
