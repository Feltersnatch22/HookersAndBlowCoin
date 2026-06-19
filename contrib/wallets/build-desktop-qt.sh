#!/usr/bin/env bash
# Native Linux build of raven-qt using system Qt5 (no depends/ Qt cross-build).
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/../.." && pwd)"
cd "$ROOT"

if ! command -v qmake >/dev/null 2>&1; then
  echo "Install Qt5 dev packages (see doc/build-ubuntu.md), e.g.:" >&2
  echo "  sudo apt install qtbase5-dev qttools5-dev libqrencode-dev libprotobuf-dev protobuf-compiler" >&2
  exit 1
fi

if ! pkg-config --exists protobuf 2>/dev/null; then
  echo "libprotobuf not found. Install libprotobuf-dev and protobuf-compiler." >&2
  exit 1
fi

# Berkeley DB 4.8 (wallet). Prefer sibling db4 from contrib/install_db4.sh.
BDB_PREFIX="${BDB_PREFIX:-}"
if [[ -z "${BDB_PREFIX}" ]]; then
  for candidate in "${ROOT}/../db4" "${ROOT}/db4"; do
    if [[ -f "${candidate}/include/db_cxx.h" ]]; then
      BDB_PREFIX="${candidate}"
      break
    fi
  done
fi
if [[ -z "${BDB_PREFIX}" ]]; then
  echo "Berkeley DB 4.8 not found. Build it first:" >&2
  echo "  ./contrib/install_db4.sh ../" >&2
  echo "  export BDB_PREFIX=\$(pwd)/../db4" >&2
  exit 1
fi

CONFIGURE_FLAGS=(
  --with-gui=qt5
  --disable-tests
  --disable-bench
  --disable-gui-tests
)

export BDB_LIBS="-L${BDB_PREFIX}/lib -ldb_cxx-4.8"
export BDB_CFLAGS="-I${BDB_PREFIX}/include"

if [[ ! -f configure ]]; then
  ./autogen.sh
fi

# Always configure for Qt + wallet (safe after headless builds).
./configure "${CONFIGURE_FLAGS[@]}"

make -j"$(nproc)" src/qt/raven-qt

echo "Built: $ROOT/src/qt/raven-qt"
