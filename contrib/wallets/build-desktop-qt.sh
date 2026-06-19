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

if [[ ! -f configure ]]; then
  ./autogen.sh
fi

if [[ ! -f Makefile ]]; then
  ./configure --with-gui=qt5 --disable-tests --disable-bench --disable-gui-tests
fi

make -j"$(nproc)" src/qt/raven-qt

echo "Built: $ROOT/src/qt/raven-qt"
