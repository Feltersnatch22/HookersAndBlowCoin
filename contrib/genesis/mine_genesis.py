#!/usr/bin/env python3
"""Mine HookersAndBlowCoin genesis blocks (X16R) for chainparams.cpp."""

import argparse
import binascii
import hashlib
import struct
import sys
import time

try:
    import x16r_hash
except ImportError:
    print("Install x16r_hash first (see contrib/genesis/README.md)", file=sys.stderr)
    sys.exit(1)

PUBKEY_HEX = (
    "04678afdb0fe5548271967f1a67130b7105cd6a828e03909a67962e0ea1f61deb649f6bc3f4cef38"
    "c4f35504e51ec112de5c384df7ba0b8d578a4c702b6bf11d5f"
)


def compact_to_target(bits: int) -> int:
    exponent = bits >> 24
    mantissa = bits & 0x007FFFFF
    if exponent <= 3:
        target = mantissa >> (8 * (3 - exponent))
    else:
        target = mantissa << (8 * (exponent - 3))
    return target


def serialize_scriptnum(value: int) -> bytes:
    if value == 0:
        return b""
    result = bytearray()
    neg = value < 0
    absvalue = -value if neg else value
    while absvalue:
        result.append(absvalue & 0xFF)
        absvalue >>= 8
    if result[-1] & 0x80:
        result.append(0x80 if neg else 0x00)
    elif neg:
        result[-1] |= 0x80
    return bytes(result)


def push_data(data: bytes) -> bytes:
    if len(data) < 0x4C:
        return bytes([len(data)]) + data
    if len(data) <= 0xFF:
        return bytes([0x4C, len(data)]) + data
    return bytes([0x4D]) + struct.pack("<H", len(data)) + data


def create_input_script(timestamp: str) -> bytes:
    script = b""
    script += push_data(serialize_scriptnum(0))
    script += push_data(serialize_scriptnum(486604799))
    script += push_data(serialize_scriptnum(4))
    script += push_data(timestamp.encode("ascii"))
    return script


def create_output_script(pubkey_hex: str) -> bytes:
    return bytes([0x41]) + bytes.fromhex(pubkey_hex) + bytes([0xAC])


def create_transaction(timestamp: str, value: int, pubkey_hex: str) -> bytes:
    input_script = create_input_script(timestamp)
    output_script = create_output_script(pubkey_hex)
    tx = struct.pack("<I", 1)  # version
    tx += bytes([1])  # vin count
    tx += b"\x00" * 32  # prevout hash
    tx += struct.pack("<I", 0xFFFFFFFF)  # prevout index
    tx += bytes([len(input_script)]) + input_script
    tx += struct.pack("<I", 0xFFFFFFFF)  # sequence
    tx += bytes([1])  # vout count
    tx += struct.pack("<Q", value)
    tx += bytes([len(output_script)]) + output_script
    tx += struct.pack("<I", 0)  # locktime
    return tx


def merkle_root(tx: bytes) -> bytes:
    return hashlib.sha256(hashlib.sha256(tx).digest()).digest()


def pow_hash(header: bytes) -> bytes:
    return x16r_hash.getPoWHash(header)


def mine(timestamp: str, n_time: int, bits: int, version: int, value: int, pubkey_hex: str, start_nonce: int = 0):
    tx = create_transaction(timestamp, value, pubkey_hex)
    root = merkle_root(tx)
    target = compact_to_target(bits)
    prev_block = b"\x00" * 32

    print(f"timestamp: {timestamp}")
    print(f"merkle root: {root[::-1].hex()}")
    print(f"time: {n_time}")
    print(f"bits: {hex(bits)}")
    print(f"target: {target:064x}")
    print("mining...")

    nonce = start_nonce
    t0 = time.time()
    report = t0
    while True:
        header = struct.pack("<I", version)
        header += prev_block
        header += root
        header += struct.pack("<III", n_time, bits, nonce)
        digest = pow_hash(header)
        hash_int = int.from_bytes(digest[::-1], "big")
        if hash_int <= target:
            elapsed = time.time() - t0
            print(f"\nfound in {elapsed:.1f}s at nonce {nonce}")
            print(f"hash: {digest[::-1].hex()}")
            print(f"nonce: {nonce}")
            print(f"merkle: {root[::-1].hex()}")
            return {
                "hash": digest[::-1].hex(),
                "nonce": nonce,
                "merkle": root[::-1].hex(),
                "time": n_time,
            }

        nonce += 1
        if nonce % 10000 == 0:
            now = time.time()
            if now - report >= 2.0:
                rate = nonce / (now - t0)
                print(f"\rnonce {nonce} ({rate:.0f} H/s) latest {digest[::-1].hex()}", end="", flush=True)
                report = now
        if nonce == 0:
            n_time += 1


def main():
    parser = argparse.ArgumentParser(description="Mine HNB genesis block (X16R)")
    parser.add_argument("-z", "--timestamp", required=True)
    parser.add_argument("-t", "--time", type=int, required=True)
    parser.add_argument("-b", "--bits", type=lambda x: int(x, 0), default=0x1E00FFFF)
    parser.add_argument("-v", "--version", type=int, default=4)
    parser.add_argument("--value", type=int, default=5000 * 100000000)
    parser.add_argument("-p", "--pubkey", default=PUBKEY_HEX)
    parser.add_argument("-n", "--nonce", type=int, default=0)
    args = parser.parse_args()
    mine(args.timestamp, args.time, args.bits, args.version, args.value, args.pubkey, args.nonce)


if __name__ == "__main__":
    main()
