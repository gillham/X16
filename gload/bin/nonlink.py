#!/usr/bin/env python
import argparse
import os
import sys


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument("-o", "--output", required=True)
    parser.add_argument("files", nargs="+")
    args = parser.parse_args()

    for file in args.files:
        if not os.path.isfile(file) or not os.access(file, os.R_OK):
            print(f"ERROR: file inaccessible: {file}")
            sys.exit(1)

    try:
        with open(args.output, "wb") as fileh:
            for file in args.files:
                fileh.write(open(file, "rb").read()[0:-2])
            # terminate with four $00 (default is only 2) which
            # simplifies the loader which expects a 4 byte header
            fileh.write(b"\x00\x00\x00\x00")
    except Exception as error:
        print(f"ERROR: {error}")


if __name__ == "__main__":
    main()
