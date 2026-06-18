#!/usr/bin/env bash
# Print mainnet schedule from chainparams and launch checklist hints.
set -euo pipefail

GENESIS_TIME=1750251600
KAWPOW_TIME=1758027600
ASSETS_START=1750251600
GENESIS_HASH="0000005bc2484f740d4c3087211e3aa44d33e7691c9dfdf099b823f735f0be2b"

now=$(date +%s)

fmt_utc() {
  date -u -d "@$1" '+%Y-%m-%d %H:%M:%S UTC' 2>/dev/null || date -u -r "$1" '+%Y-%m-%d %H:%M:%S UTC'
}

delta() {
  local target=$1
  local diff=$((target - now))
  local abs=${diff#-}
  local days=$((abs / 86400))
  local hours=$(((abs % 86400) / 3600))
  local mins=$(((abs % 3600) / 60))
  if (( diff > 0 )); then
    echo "in ${days}d ${hours}h ${mins}m"
  elif (( diff < 0 )); then
    echo "${days}d ${hours}h ${mins}m ago"
  else
    echo "now"
  fi
}

echo "=== HookersAndBlowCoin mainnet schedule ==="
echo "Current time:     $(fmt_utc "$now")"
echo ""
echo "Genesis (chain):  $(fmt_utc "$GENESIS_TIME")  ($(delta "$GENESIS_TIME"))"
echo "  hash:           $GENESIS_HASH"
echo "KawPow activate:  $(fmt_utc "$KAWPOW_TIME")  ($(delta "$KAWPOW_TIME"))"
echo "Assets BIP9 start:$(fmt_utc "$ASSETS_START")  ($(delta "$ASSETS_START"))"
echo ""
echo "Ports: P2P 28888 · RPC 28887"
echo ""

if (( now >= GENESIS_TIME )); then
  echo "Genesis timestamp is in the past — ready to start seed nodes when binaries and seeds are deployed."
else
  echo "Genesis timestamp is still in the future — start seed nodes after $(fmt_utc "$GENESIS_TIME")."
fi

if command -v curl >/dev/null 2>&1; then
  echo ""
  echo "Latest GitHub release:"
  curl -fsSL "https://api.github.com/repos/Feltersnatch22/HookersAndBlowCoin/releases/latest" \
    | grep -E '"tag_name"|"html_url"' | head -2 || echo "  (none published yet — cut a release from a release* branch)"
fi
