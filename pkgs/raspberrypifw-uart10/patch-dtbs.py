#!/usr/bin/env python3
# Patch Raspberry Pi 5 family DTBs so U-Boot can bind the debug UART.
#
# The prebuilt bcm2712* DTBs shipped in raspberrypi/firmware (as of
# raspberrypifw 1.20260521 and firmware master) declare the debug UART
# (uart10, //soc@107c000000/serial@7d001000, the node chosen/stdout-path
# points at) as:
#
#     compatible = "arm,pl011-axi", "arm,pl011", "arm,primecell"
#
# U-Boot's pl01x serial driver cannot bind "arm,pl011-axi", so U-Boot
# draws its splash logo and then wedges before reading extlinux.conf.
# The RPi kernel DTS (bcm2712.dtsi, 6.18+) uses plain "arm,pl011".
#
# This rewrites the first compatible entry in place, NUL-padded to the
# same byte length so all FDT offsets stay valid.
#
# Usage:
#   patch-dtbs.py check [FILE|DIR]...   # report only
#   patch-dtbs.py patch [FILE|DIR]...   # patch in place (dirs: all *.dtb)
import glob
import os
import struct
import sys

BAD = b"arm,pl011-axi"
GOOD = b"arm,pl011"


def walk(data, off_struct, off_strings):
    """Yield (nodepath, name, valpos, lenp, value) for every property."""
    strings = bytes(data[off_strings:])
    pos = off_struct
    path = []
    while pos < off_strings:
        token = struct.unpack(">I", data[pos:pos + 4])[0]
        pos += 4
        if token == 1:  # BEGIN_NODE
            end = data.index(b"\0", pos)
            name = data[pos:end].decode()
            pos = (end + 1 + 3) & ~3
            path.append(name)
        elif token == 2:  # END_NODE
            path.pop()
        elif token == 3:  # PROP
            lenp, nameoff = struct.unpack(">II", data[pos:pos + 8])
            pos += 8
            val = pos
            pos = (pos + lenp + 3) & ~3
            name = strings[nameoff:strings.index(b"\0", nameoff)].decode()
            yield "/" + "/".join(path), name, val, lenp, bytes(data[val:val + lenp])
        elif token == 4:  # NOP
            continue
        elif token == 9:  # FDT_END
            return
        else:
            raise ValueError(f"unexpected token {token:#x} at {pos:#x}")


def collect_files(args):
    files = []
    for a in args:
        if os.path.isdir(a):
            files += sorted(glob.glob(os.path.join(a, "*.dtb")))
            files += sorted(glob.glob(os.path.join(a, "broadcom", "*.dtb")))
        else:
            files.append(a)
    return files


def main():
    mode, args = sys.argv[1], sys.argv[2:]
    assert mode in ("check", "patch"), "usage: patch-dtbs.py check|patch FILE|DIR..."
    patched = skipped = 0
    for fn in collect_files(args):
        try:
            data = bytearray(open(fn, "rb").read())
            hdr = struct.unpack(">10I", data[:40])
            if hdr[0] != 0xD00DFEED:
                print(f"{fn}: not a DTB, skipping")
                continue
            props = list(walk(data, hdr[2], hdr[3]))
        except Exception as e:  # noqa: BLE001
            print(f"{fn}: ERROR {e}")
            continue
        for path, name, val, lenp, value in props:
            if not (path.endswith("serial@7d001000") and name == "compatible"):
                continue
            entries = value.split(b"\0")
            if entries[0] != BAD:
                print(f"{fn}: uart10 compatible ok: {entries[:3]}")
                skipped += 1
                continue
            print(f"{fn}: uart10 compatible BAD: {[e.decode() for e in entries if e]}")
            if mode != "patch":
                continue
            first = BAD + b"\0"
            assert value.startswith(first) and GOOD + b"\0" in value[len(first):]
            # "arm,pl011-axi\0" (14 bytes) -> "arm,pl011\0" + 4 NULs
            new = GOOD + b"\0" + b"\0" * (len(first) - len(GOOD) - 1) + value[len(first):]
            assert len(new) == lenp
            data[val:val + lenp] = new
            open(fn, "wb").write(bytes(data))
            print(f"{fn}: PATCHED uart10 compatible[0] -> arm,pl011")
            patched += 1
    if mode == "patch":
        print(f"done: {patched} patched, {skipped} already ok")
    return 0


if __name__ == "__main__":
    sys.exit(main())
