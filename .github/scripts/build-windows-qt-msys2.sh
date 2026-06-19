#!/usr/bin/env bash
# Native Windows Qt wallet build inside MSYS2 MINGW64 (GitHub Actions or local MSYS2).
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/../.." && pwd)"
cd "$ROOT"

case "${MSYSTEM:-MINGW64}" in
  MINGW64) MSYSTEM_PREFIX=/mingw64 ;;
  UCRT64)  MSYSTEM_PREFIX=/ucrt64 ;;
  *)       MSYSTEM_PREFIX=/mingw64 ;;
esac
export PATH="${MSYSTEM_PREFIX}/bin:/usr/bin:$PATH"
export MAKEFLAGS="-j$(nproc)"

# MSYS2 Qt5 packages use qmake-qt5 / windeployqt-qt5; autotools expect qmake.
for tool in qmake windeployqt; do
  if ! command -v "$tool" >/dev/null 2>&1 && command -v "${tool}-qt5" >/dev/null 2>&1; then
    ln -sf "${tool}-qt5" "${MSYSTEM_PREFIX}/bin/${tool}"
  fi
done

if ! command -v qmake >/dev/null 2>&1; then
  echo "qmake not found under ${MSYSTEM_PREFIX}/bin:" >&2
  ls -la "${MSYSTEM_PREFIX}/bin"/qmake* 2>/dev/null || true
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
