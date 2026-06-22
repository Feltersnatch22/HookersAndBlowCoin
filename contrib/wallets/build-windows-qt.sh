#!/usr/bin/env bash
# Cross-compile hnb-qt.exe for Windows from Linux or WSL.
# Requires: mingw-w64, depends/ Qt build (~1–2 hours first run).
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/../.." && pwd)"
HOST="${HOST:-x86_64-w64-mingw32}"
JOBS="${JOBS:-$(nproc)}"
RELEASE_DIR="${RELEASE_DIR:-$ROOT/release}"

cd "$ROOT"

echo "==> Generating HNB Qt icons"
python3 "$ROOT/contrib/qt/generate-hnb-icons.py"
if command -v rcc >/dev/null 2>&1; then
  rcc -name raven "$ROOT/src/qt/raven.qrc" -o "$ROOT/src/qt/qrc_raven.cpp"
fi

# WSL: strip Windows PATH entries that break the toolchain
if grep -qi microsoft /proc/version 2>/dev/null; then
  export PATH="$(echo "$PATH" | sed -e 's/:\/mnt.*//g')"
fi

if ! command -v "${HOST}-g++" >/dev/null 2>&1; then
  cat >&2 <<'EOF'
Missing mingw cross compiler. Install (Debian/Ubuntu):

  sudo apt install build-essential libtool autotools-dev automake pkg-config \
    bsdmainutils curl nsis git bison \
    g++-mingw-w64-x86-64 mingw-w64-x86-64-dev

  sudo update-alternatives --set x86_64-w64-mingw32-g++ /usr/bin/x86_64-w64-mingw32-g++-posix
  sudo update-alternatives --set x86_64-w64-mingw32-gcc /usr/bin/x86_64-w64-mingw32-gcc-posix

On Windows, use MSYS2 instead: contrib/wallets/build-windows-qt-msys2.sh
EOF
  exit 1
fi

echo "==> Building depends for ${HOST} (includes Qt 5.12 — first run is slow)"
make -C depends HOST="$HOST" -j"$JOBS"

export PATH="$ROOT/depends/${HOST}/native/bin:$PATH"

echo "==> Regenerating Qt protobuf stubs (protoc 2.6 from depends)"
protoc --cpp_out="$ROOT/src/qt" -I"$ROOT/src/qt" "$ROOT/src/qt/paymentrequest.proto"

if [[ ! -f configure ]]; then
  ./autogen.sh
fi

if [[ -f Makefile ]]; then
  echo "==> Cleaning previous build tree"
  make distclean || true
fi

echo "==> Configuring HNB Wallet for Windows"
CONFIG_SITE="$ROOT/depends/${HOST}/share/config.site" ./configure \
  --prefix=/ \
  --with-qtdbus=no \
  --disable-ccache \
  --disable-maintainer-mode \
  --disable-dependency-tracking \
  --enable-reduce-exports \
  --disable-bench \
  --disable-tests \
  --disable-gui-tests \
  --enable-shared=no \
  CFLAGS="-O2 -g" \
  CXXFLAGS="-O2 -g"

echo "==> Building hnbd, hnb-cli, hnb-qt"
# Build static libs first to avoid parallel link races on mingw.
make -C src -j1 libraven_wallet.a qt/libravenqt.a
make -C src -j"$JOBS" hnbd.exe hnb-cli.exe
make -C src -j1 qt/hnb-qt.exe

echo "==> Packaging"
OUT_DIR="$RELEASE_DIR" GITHUB_REF_NAME="${GITHUB_REF_NAME:-}" \
  "$ROOT/contrib/wallets/package-windows-qt.sh"

echo "Done. Windows GUI + CLI in ${RELEASE_DIR}/"
