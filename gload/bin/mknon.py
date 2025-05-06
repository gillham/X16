#!/usr/bin/env python
"""
This script creates a nonlinear "segment" from an existing file.
"""
import argparse
import sys


def main():
    banked = False
    parser = argparse.ArgumentParser()
    parser.add_argument("-a", "--address")
    parser.add_argument("-b", "--bank")
    parser.add_argument("-i", "--input", required=True)
    parser.add_argument("-o", "--output", required=True)
    parser.add_argument("-u", "--usefileaddress", action="store_true")
    args = parser.parse_args()

    data = open(args.input, "rb").read()

    if not args.bank and not (args.address or args.usefileaddress):
        print("Non-banked needs --address or --usefileaddress")
        print("--address 0801 for example (use hex)")
        print("--usefileaddress will use the first two bytes of the file.")
        print("Those two bytes will not be written to the output.")
        sys.exit(1)

    if args.address:
        try:
            loadaddress = int(args.address, 16)
        except:
            print("ERROR in load address, must be hex no prefix")
            sys.exit(1)

    if args.bank:
        loadaddress = 0xA000
        banked = True
        print("INFO: generating banked nonlinear file.")
        start_bank = int(args.bank)
        banks = int(len(data) / 8192)
        last_bytes = len(data) % 8192
        # print(f"DEBUG:     banks: {banks} last_bytes: {last_bytes}")

    offset = 0
    with open(args.output, "wb") as fileh:
        if banked:
            for bank in range(start_bank, start_bank + banks):
                # 1 byte to $0000
                fileh.write(b"\x01\x00\x00\x00")
                fileh.write(bank.to_bytes(1, "little"))
                print(f"INFO: bank: {bank} offset: {offset} end: {offset+8192}")
                # 8KB at $A000
                fileh.write(b"\x00\x20\x00\xa0")
                fileh.write(data[offset : offset + 8192])
                offset += 8192

            # remaining bytes / last bank
            if last_bytes > 0:
                fileh.write(b"\x01\x00\x00\x00")
                fileh.write((start_bank + banks).to_bytes(1, "little"))
                fileh.write(last_bytes.to_bytes(2, "little"))
                fileh.write(b"\x00\xa0")
                print(
                    f"INFO: bank: {start_bank+banks} offset: "
                    + f"{offset} end: {offset+last_bytes}"
                )
                fileh.write(data[offset : offset + last_bytes])
            fileh.write(b"\x00\x00")
        else:
            # not banked -- regular file.
            if not args.usefileaddress:
                fileh.write(len(data).to_bytes(2, "little"))
                fileh.write(loadaddress.to_bytes(2, "little"))
            else:
                # subtract two for the load address
                fileh.write((len(data) - 2).to_bytes(2, "little"))

            fileh.write(data)
            # standard nonlinear terminator
            fileh.write(b"\x00\x00")


if __name__ == "__main__":
    main()
