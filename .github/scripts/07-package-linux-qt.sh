#!/usr/bin/env bash
# CI: package hnb-qt built by build-desktop-qt.sh
set -euo pipefail

GITHUB_WORKSPACE=${1:?}
GITHUB_REF=${2:-}
cd "$GITHUB_WORKSPACE"

export QT_BIN="$GITHUB_WORKSPACE/src/qt/hnb-qt"
export OUT_DIR="$GITHUB_WORKSPACE/release"
export GITHUB_REF_NAME="${GITHUB_REF#refs/heads/}"
./contrib/wallets/package-linux-qt.sh
