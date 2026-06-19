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
export PKG_CONFIG="${MSYSTEM_PREFIX}/bin/pkg-config"
export PKG_CONFIG_PATH="${MSYSTEM_PREFIX}/lib/qt5/pkgconfig:${MSYSTEM_PREFIX}/share/pkgconfig:${PKG_CONFIG_PATH:-}"
export MAKEFLAGS="-j$(nproc)"
export BOOST_ROOT="${MSYSTEM_PREFIX}"
export CONFIG_SITE="$(dirname "$0")/msys2-config.site"
export LDFLAGS="-L${MSYSTEM_PREFIX}/lib ${LDFLAGS:-}"
export CPPFLAGS="-I${MSYSTEM_PREFIX}/include ${CPPFLAGS:-}"
# boost_filesystem/thread/chrono link against boost_system during ax_boost AC_CHECK_LIB tests.
export LIBS="-lboost_system ${LIBS:-}"

# MSYS2 Qt5 packages use qmake-qt5 / windeployqt-qt5; autotools expect qmake.
for tool in qmake windeployqt; do
  if ! command -v "$tool" >/dev/null 2>&1 && command -v "${tool}-qt5" >/dev/null 2>&1; then
    ln -sf "${tool}-qt5" "${MSYSTEM_PREFIX}/bin/${tool}"
  fi
done

if ! pkg-config --exists Qt5Core; then
  echo "Qt5Core pkg-config missing. PKG_CONFIG_PATH=${PKG_CONFIG_PATH}" >&2
  pkg-config --list-all | grep -i qt5 | head -20 || true
  exit 1
fi

if ! command -v qmake >/dev/null 2>&1; then
  echo "qmake not found under ${MSYSTEM_PREFIX}/bin:" >&2
  ls -la "${MSYSTEM_PREFIX}/bin"/qmake* 2>/dev/null || true
  exit 1
fi

./autogen.sh

./configure \
  --with-gui=qt5 \
  --with-incompatible-bdb \
  --with-boost="${MSYSTEM_PREFIX}" \
  --with-boost-libdir="${MSYSTEM_PREFIX}/lib" \
  --with-qt-bindir="${MSYSTEM_PREFIX}/bin" \
  --with-qt-incdir="${MSYSTEM_PREFIX}/include/qt5" \
  --with-qt-libdir="${MSYSTEM_PREFIX}/lib" \
  --disable-tests \
  --disable-bench \
  --disable-gui-tests \
  --disable-reduce-exports

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
