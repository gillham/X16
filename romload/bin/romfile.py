#!/usr/bin/env python3

with open("romfile.bin", "wb") as outf:
    for i in range(32, 64):
        outf.write(i.to_bytes(1)*16384)

