#!/usr/bin/env python
"""
This script reads 64tass style nonlinear files and
dumps the size and load address of each segment.
"""
import argparse
import sys


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument("file")
    args = parser.parse_args()
    # data_count = 0
    try:
        data = open(args.file, "rb").read()
    except:
        print("ERROR reading file.")
        sys.exit(1)
    data_size = len(data)
    offset = 0
    print("  addr bytes")
    while offset < data_size:
        count = int.from_bytes(data[offset : offset + 2], "little")
        if count == 0:
            print("# eof #")
            break
        offset += 2
        address = int.from_bytes(data[offset : offset + 2], "little")
        offset += 2
        print(f"L {address:04x} {count:04x}")

        # now skip over file content to next header
        offset += count
        # break


if __name__ == "__main__":
    main()
