#!/usr/bin/env bash
# Package cross-compiled Windows binaries (GUI + CLI) into release zip.
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/../.." && pwd)"
cd "$ROOT"

OUT_DIR="${OUT_DIR:-$ROOT/release}"
PKGVERSION="$(grep 'PACKAGE_VERSION' src/config/raven-config.h | cut -d\" -f2)"
SHORTHASH="$(git rev-parse --short HEAD 2>/dev/null || echo local)"
if [[ "${GITHUB_REF_NAME:-}" =~ ^release ]]; then
  DISTNAME="hnb-${PKGVERSION}"
else
  DISTNAME="hnb-${PKGVERSION}-${SHORTHASH}"
fi

STAGE="$OUT_DIR/stage-win/$DISTNAME"
rm -rf "$STAGE"
mkdir -p "$STAGE"

if [[ -x src/qt/hnb-qt.exe ]]; then
  make install DESTDIR="$STAGE" >/dev/null
else
  echo "Missing src/qt/hnb-qt.exe — run build-windows-qt.sh first" >&2
  exit 1
fi

cd "$OUT_DIR/stage-win"
mv "${DISTNAME}/bin/"*.dll "${DISTNAME}/lib/" 2>/dev/null || true
find . -name "lib*.la" -delete
find . -name "lib*.a" -delete
rm -rf "${DISTNAME}/lib/pkgconfig"

if command -v x86_64-w64-mingw32-objcopy >/dev/null 2>&1; then
  find "${DISTNAME}/bin" -type f -executable -exec x86_64-w64-mingw32-objcopy \
    --only-keep-debug {} {}.dbg \; -exec x86_64-w64-mingw32-strip -s {} \; \
    -exec x86_64-w64-mingw32-objcopy --add-gnu-debuglink={}.dbg {} \;
fi

cat > "${DISTNAME}/README.txt" <<'EOF'
HNB Wallet for Windows (64-bit)
===============================

Includes: hnb-qt.exe (HNB Wallet GUI), hnbd.exe, hnb-cli.exe

1. Extract the zip
2. Run hnb-qt.exe
3. For testnet, create %APPDATA%\HookersAndBlow\raven.conf with:
     testnet=1
     addnode=100.80.138.89:28890
   Then restart hnb-qt.exe
   (Or run: hnb-qt.exe -testnet)
4. Testnet window title shows "HNB Wallet Testnet" with a green-tinted icon

Keep all .dll files in lib/ next to the executables (or run from extracted folder).

Web wallet: https://hookersandblow.vercel.app/wallet/
EOF

mkdir -p "$OUT_DIR"
ZIP="$OUT_DIR/${DISTNAME}-win64-qt.zip"
find "./${DISTNAME}" -not -name "*.dbg" -type f | sort | zip -X@ "$ZIP"
(
  cd "$OUT_DIR"
  md5sum "$(basename "$ZIP")" > "$(basename "$ZIP").md5sum"
  sha256sum "$(basename "$ZIP")" > "$(basename "$ZIP").sha256sum"
)

echo "Packaged: $ZIP"
ls -lh "$ZIP"
