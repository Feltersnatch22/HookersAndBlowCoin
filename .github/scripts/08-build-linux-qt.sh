#!/usr/bin/env bash
# CI: build hnb-qt with system Qt + BDB 4.8
set -euo pipefail

GITHUB_WORKSPACE=${1:?}
cd "$GITHUB_WORKSPACE"

./contrib/install_db4.sh ../
export BDB_PREFIX="$GITHUB_WORKSPACE/../db4"
./contrib/wallets/build-desktop-qt.sh
