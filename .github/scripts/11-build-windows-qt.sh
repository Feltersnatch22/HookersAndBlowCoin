#!/usr/bin/env bash
set -euo pipefail
GITHUB_WORKSPACE=${1:?}
cd "$GITHUB_WORKSPACE"
export PATH="$GITHUB_WORKSPACE/depends/x86_64-w64-mingw32/native/bin:$PATH"
protoc --cpp_out="$GITHUB_WORKSPACE/src/qt" -I"$GITHUB_WORKSPACE/src/qt" "$GITHUB_WORKSPACE/src/qt/paymentrequest.proto"
./autogen.sh
if [[ -f Makefile ]]; then make distclean || true; fi
CONFIG_SITE="$GITHUB_WORKSPACE/depends/x86_64-w64-mingw32/share/config.site" ./configure \
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
make -j2 src/hnbd.exe src/hnb-cli.exe src/qt/hnb-qt.exe
