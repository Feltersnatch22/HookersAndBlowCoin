#!/usr/bin/env bash
# Native Windows Qt wallet build inside MSYS2 MINGW64 (GitHub Actions or local MSYS2).
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/../.." && pwd)"
cd "$ROOT"

export PATH="/mingw64/bin:$PATH"
export MAKEFLAGS="-j$(nproc)"

if ! command -v qmake >/dev/null 2>&1; then
  echo "qmake not found — run from MSYS2 MINGW64 with mingw-w64-x86_64-qt5 installed" >&2
  exit 1
fi

./autogen.sh

./configure \
  --with-gui=qt5 \
  --with-incompatible-bdb \
  --disable-tests \
  --disable-bench \
  --disable-gui-tests \
  --enable-reduce-exports

make -j"$(nproc)"

QT_BIN="src/qt/raven-qt.exe"
if [[ ! -f "$QT_BIN" ]]; then
  echo "Build failed: $QT_BIN not found" >&2
  exit 1
fi

PKGVERSION="$(grep PACKAGE_VERSION src/config/raven-config.h | cut -d\" -f2)"
DISTNAME="raven-${PKGVERSION}"
STAGE="${ROOT}/stage/${DISTNAME}-win64-qt"
RELEASE="${ROOT}/release"
rm -rf "$STAGE"
mkdir -p "$STAGE" "$RELEASE"

cp "$QT_BIN" "$STAGE/"
[[ -f src/ravend.exe ]] && cp src/ravend.exe "$STAGE/"
[[ -f src/raven-cli.exe ]] && cp src/raven-cli.exe "$STAGE/"

# Bundle Qt runtime DLLs and plugins next to the GUI binary.
windeployqt --no-translations "$STAGE/raven-qt.exe"

(
  cd "$(dirname "$STAGE")"
  rm -f "${RELEASE}/${DISTNAME}-win64-qt.zip"
  powershell.exe -NoProfile -Command "Compress-Archive -Path '${DISTNAME}-win64-qt/*' -DestinationPath '${RELEASE}/${DISTNAME}-win64-qt.zip' -Force" \
    || zip -r "${RELEASE}/${DISTNAME}-win64-qt.zip" "${DISTNAME}-win64-qt"
)

echo "Built: ${RELEASE}/${DISTNAME}-win64-qt.zip"
