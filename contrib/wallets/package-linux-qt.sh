#!/usr/bin/env bash
# Package native Linux hnb-qt into a release tarball.
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/../.." && pwd)"
cd "$ROOT"

QT_BIN="${QT_BIN:-$ROOT/src/qt/hnb-qt}"
OUT_DIR="${OUT_DIR:-$ROOT/release}"
PKGVERSION="$(grep 'PACKAGE_VERSION' src/config/raven-config.h | cut -d\" -f2)"
SHORTHASH="$(git rev-parse --short HEAD 2>/dev/null || echo local)"
if [[ "${GITHUB_REF_NAME:-}" =~ ^release ]]; then
  DISTNAME="${DISTNAME:-hnb-${PKGVERSION}-x86_64-linux-gnu-qt}"
else
  DISTNAME="${DISTNAME:-hnb-${PKGVERSION}-${SHORTHASH}-x86_64-linux-gnu-qt}"
fi
STAGE="$OUT_DIR/stage-qt/$DISTNAME"

if [[ ! -x "$QT_BIN" ]]; then
  echo "Missing hnb-qt. Build first: ./contrib/wallets/build-desktop-qt.sh" >&2
  exit 1
fi

rm -rf "$STAGE"
mkdir -p "$STAGE/bin"
cp "$QT_BIN" "$STAGE/bin/hnb-qt"
strip "$STAGE/bin/hnb-qt" 2>/dev/null || true

cat > "$STAGE/README.txt" <<'EOF'
HNB Desktop Wallet (hnb-qt) — Linux x86_64
============================================

Includes: hnb-qt (Qt GUI wallet + full node)

System requirements (Ubuntu/Debian example):
  sudo apt install qtbase5-dev libqt5gui5 libqt5widgets5 libqt5network5 \
    libqt5dbus5 libqrencode4 libprotobuf23 zlib1g libminiupnpc17

Run:
  tar xzf hnb-*-linux-gnu-qt.tar.gz
  cd hnb-*-linux-gnu-qt
  ./bin/hnb-qt

Testnet: add `testnet=1` to `~/.hnb/hnb.conf` or run `hnb-qt -testnet` (P2P 28890, RPC 28889)
Mainnet: P2P 28888, RPC 28887

Headless node only? Use the CLI release (hnbd + hnb-cli).
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
