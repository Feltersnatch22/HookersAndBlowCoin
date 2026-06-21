#!/usr/bin/env bash
# Package locally built ravend + raven-cli (no make install / depends required).
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/../.." && pwd)"
cd "$ROOT"

RAVEND="${RAVEND:-$ROOT/src/hnbd}"
CLI="${CLI:-$ROOT/src/hnb-cli}"
OUT_DIR="${OUT_DIR:-$ROOT/release}"
PKGVERSION="$(grep 'PACKAGE_VERSION' src/config/raven-config.h | cut -d\" -f2)"
SHORTHASH="$(git rev-parse --short HEAD 2>/dev/null || echo local)"
DISTNAME="${DISTNAME:-hnb-${PKGVERSION}-${SHORTHASH}-x86_64-linux-gnu}"
STAGE="$OUT_DIR/stage-cli/$DISTNAME"

for bin in "$RAVEND" "$CLI"; do
  if [[ ! -x "$bin" ]]; then
    echo "Missing $bin — run: make -j\$(nproc) src/hnbd src/hnb-cli" >&2
    exit 1
  fi
done

rm -rf "$STAGE"
mkdir -p "$STAGE/bin"
cp "$RAVEND" "$STAGE/bin/hnbd"
cp "$CLI" "$STAGE/bin/hnb-cli"
strip "$STAGE/bin/ravend" "$STAGE/bin/raven-cli" 2>/dev/null || true

cat > "$STAGE/README.txt" <<'EOF'
HNB Node + CLI — Linux x86_64 (headless)
========================================

Includes: ravend (daemon), raven-cli (RPC client)

Quick start (testnet):
  ./bin/ravend -testnet -daemon -bypassdownload
  ./bin/raven-cli -testnet getblockchaininfo

Config: ~/.raven/raven.conf
  testnet=1
  server=1
  rpcuser=hnb
  rpcpassword=CHANGE_ME

GUI wallet: use the *-linux-gnu-qt.tar.gz release or build raven-qt.
Web wallet: https://hookersandblow.vercel.app/wallet/
EOF

mkdir -p "$OUT_DIR"
TARBALL="$OUT_DIR/${DISTNAME}.tar.gz"
tar -C "$(dirname "$STAGE")" -czf "$TARBALL" "$(basename "$STAGE")"
(
  cd "$OUT_DIR"
  md5sum "$(basename "$TARBALL")" > "$(basename "$TARBALL").md5sum"
  sha256sum "$(basename "$TARBALL")" > "$(basename "$TARBALL").sha256sum"
)

echo "Packaged: $TARBALL"
ls -lh "$TARBALL"
