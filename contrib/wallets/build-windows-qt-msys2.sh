#!/usr/bin/env bash
# Build hnb-qt.exe natively on Windows using MSYS2 MINGW64.
# Run inside "MSYS2 MinGW 64-bit" terminal (not MSYS).
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/../.." && pwd)"
cd "$ROOT"

if ! command -v pacman >/dev/null 2>&1; then
  echo "Run this script from MSYS2 (https://www.msys2.org/)." >&2
  exit 1
fi

if [[ "$(uname -o 2>/dev/null || true)" != *Msys* ]] && [[ -z "${MSYSTEM:-}" ]]; then
  echo "Use the MSYS2 MinGW 64-bit shell (MSYSTEM=MINGW64)." >&2
  exit 1
fi

echo "==> Installing MSYS2 build dependencies (may prompt)"
pacman -S --needed --noconfirm \
  base-devel \
  mingw-w64-x86_64-toolchain \
  mingw-w64-x86_64-qt5 \
  mingw-w64-x86_64-boost \
  mingw-w64-x86_64-zeromq \
  mingw-w64-x86_64-miniupnpc \
  mingw-w64-x86_64-libsodium \
  mingw-w64-x86_64-hidapi \
  autoconf automake libtool make pkg-config patch git

if [[ ! -f "$ROOT/db4/include/db_cxx.h" ]]; then
  echo "==> Building Berkeley DB 4.8"
  ./contrib/install_db4.sh ./
fi
export BDB_PREFIX="$ROOT/db4"

if [[ ! -f configure ]]; then
  ./autogen.sh
fi

echo "==> Configuring"
./configure \
  --with-gui=qt5 \
  --disable-tests \
  --disable-bench \
  --disable-gui-tests \
  BDB_LIBS="-L${BDB_PREFIX}/lib -ldb_cxx-4.8" \
  BDB_CFLAGS="-I${BDB_PREFIX}/include"

echo "==> Building"
make -j"$(nproc)" src/qt/hnb-qt.exe src/hnb-cli.exe src/hnbd.exe

OUT_DIR="${OUT_DIR:-$ROOT/release}"
mkdir -p "$OUT_DIR"
cp -f src/qt/hnb-qt.exe src/hnb-cli.exe src/hnbd.exe "$OUT_DIR/"
echo "Built: $OUT_DIR/hnb-qt.exe"
echo "Copy Qt DLLs with: windeployqt release/hnb-qt.exe (Qt5)"
