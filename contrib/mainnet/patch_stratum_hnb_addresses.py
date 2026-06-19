#!/usr/bin/env python3
"""Patch ravencoin-stratum-proxy for HNB mainnet address prefix (40, not Raven 60).

Usage:
  python3 patch_stratum_hnb_addresses.py ~/ravencoin-stratum-proxy/stratum-converter.py
"""
from pathlib import Path
import sys

OLD = "if addr_decoded[0] != (111 if self._testnet else 60):"
NEW = "if addr_decoded[0] != (111 if self._testnet else 40):"


def main() -> None:
    if len(sys.argv) != 2:
        print(f"Usage: {sys.argv[0]} /path/to/stratum-converter.py", file=sys.stderr)
        sys.exit(1)
    path = Path(sys.argv[1])
    text = path.read_text()
    if NEW in text:
        print("already patched")
        return
    if OLD not in text:
        raise SystemExit(f"Could not find expected line in {path}")
    path.write_text(text.replace(OLD, NEW, 1))
    print(f"patched {path}: mainnet pubkey prefix 60 -> 40")


if __name__ == "__main__":
    main()
