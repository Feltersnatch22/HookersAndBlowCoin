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
# MSYS2 ships Berkeley DB 6.x (not 4.8); bypass autoconf header probing with explicit flags.
export BDB_CFLAGS="-I${MSYSTEM_PREFIX}/include"
export BDB_LIBS="-L${MSYSTEM_PREFIX}/lib -ldb_cxx"
# boost_filesystem/thread/chrono link against boost_system during ax_boost AC_CHECK_LIB tests.
export LIBS="-lboost_system ${LIBS:-}"

# MSYS2 Qt5 packages use *-qt5 tool names; autotools expect unprefixed names.
for tool in qmake windeployqt moc uic rcc lrelease; do
  if ! command -v "$tool" >/dev/null 2>&1 && command -v "${tool}-qt5" >/dev/null 2>&1; then
    ln -sf "${tool}-qt5" "${MSYSTEM_PREFIX}/bin/${tool}"
  fi
done

echo "=== MSYS2 dependency probe ==="
ls -la "${MSYSTEM_PREFIX}/include/db_cxx.h" 2>/dev/null || echo "missing: db_cxx.h"
command -v protoc && protoc --version || echo "missing: protoc"
command -v windres || echo "missing: windres"
pkg-config --modversion Qt5Core || true
pkg-config --modversion protobuf || true
pkg-config --modversion libssl || true
ls "${MSYSTEM_PREFIX}/lib"/libboost_system* 2>/dev/null | head -3 || true

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

if ! ./configure \
  --with-gui=qt5 \
  --with-incompatible-bdb \
  --with-boost="${MSYSTEM_PREFIX}" \
  --with-boost-libdir="${MSYSTEM_PREFIX}/lib" \
  --with-qt-bindir="${MSYSTEM_PREFIX}/bin" \
  --with-qt-incdir="${MSYSTEM_PREFIX}/include/qt5" \
  --with-qt-libdir="${MSYSTEM_PREFIX}/lib" \
  --with-protoc-bindir="${MSYSTEM_PREFIX}/bin" \
  --disable-tests \
  --disable-bench \
  --disable-gui-tests \
  --disable-reduce-exports 2>&1 | tee configure.out; then
  echo "=== configure failed ===" >&2
  tail -n 60 configure.out >&2 || true
  if [[ -f config.log ]]; then
    echo "=== config.log (errors) ===" >&2
    grep -E 'configure: error|error:|Error |failed|FAILED' config.log | tail -n 40 >&2 || true
  fi
  exit 77
fi

make -j"$(nproc)"

QT_BIN="src/qt/hnb-qt.exe"
if [[ ! -f "$QT_BIN" ]]; then
  echo "Build failed: $QT_BIN not found" >&2
  exit 1
fi

PKGVERSION="$(grep PACKAGE_VERSION src/config/raven-config.h | cut -d\" -f2)"
DISTNAME="hnb-${PKGVERSION}"
STAGE="${ROOT}/stage/${DISTNAME}-win64-qt"
RELEASE="${ROOT}/release"
rm -rf "$STAGE"
mkdir -p "$STAGE" "$RELEASE"

cp "$QT_BIN" "$STAGE/"
[[ -f src/hnbd.exe ]] && cp src/hnbd.exe "$STAGE/"
[[ -f src/hnb-cli.exe ]] && cp src/hnb-cli.exe "$STAGE/"

# Bundle Qt runtime DLLs and plugins next to the GUI binary.
windeployqt --no-translations "$STAGE/hnb-qt.exe"

(
  cd "$(dirname "$STAGE")"
  rm -f "${RELEASE}/${DISTNAME}-win64-qt.zip"
  powershell.exe -NoProfile -Command "Compress-Archive -Path '${DISTNAME}-win64-qt/*' -DestinationPath '${RELEASE}/${DISTNAME}-win64-qt.zip' -Force" \
    || zip -r "${RELEASE}/${DISTNAME}-win64-qt.zip" "${DISTNAME}-win64-qt"
)

echo "Built: ${RELEASE}/${DISTNAME}-win64-qt.zip"
