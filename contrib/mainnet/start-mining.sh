#!/usr/bin/env bash
# Start HNB mainnet node, KawPow stratum proxy, and kawpowminer (Docker).
set -euo pipefail

HNB_ROOT="${HNB_ROOT:-$HOME/code/hnbcoin/HookersAndBlowCoin}"
PROXY_DIR="${PROXY_DIR:-$HOME/ravencoin-stratum-proxy}"
CONF="${CONF:-$HOME/.raven/mainnet.conf}"
MINING_ADDR="${MINING_ADDR:-}"
RPC_USER="${RPC_USER:-hnb}"
RPC_PASS="${RPC_PASS:-hnb_dev_password_change_me}"
STRATUM_PORT="${STRATUM_PORT:-3334}"
RPC_PORT="${RPC_PORT:-28887}"
MINER_CONTAINER="${MINER_CONTAINER:-kawpowminer-mainnet}"
MINER_IMAGE="${MINER_IMAGE:-kawpowminer-5090-docker-kawpowminer}"
MINER_POOL_USER="${MINER_POOL_USER:-worker}"

cd "$HNB_ROOT"
CLI="./src/raven-cli"
DAEMON="./src/ravend"

if [[ -z "$MINING_ADDR" ]]; then
  MINING_ADDR="$($CLI -conf="$CONF" getnewaddress)"
  echo "Generated mining address: $MINING_ADDR"
fi

if pgrep -f "[/]ravend.*mainnet.conf" >/dev/null; then
  $CLI -conf="$CONF" stop >/dev/null 2>&1 || true
  sleep 4
fi

$DAEMON -daemon -bypassdownload -conf="$CONF" -miningaddress="$MINING_ADDR"
sleep 3

if ! $CLI -conf="$CONF" getblockcount >/dev/null 2>&1; then
  echo "ravend RPC not responding on mainnet (port $RPC_PORT)" >&2
  exit 1
fi

if ! pgrep -f "[s]tratum-converter.py ${STRATUM_PORT}" >/dev/null; then
  if [[ ! -f "$PROXY_DIR/.venv/bin/python" ]]; then
    echo "Missing $PROXY_DIR/.venv — see contrib/testnet/README.md (proxy setup)" >&2
    exit 1
  fi
  cd "$PROXY_DIR"
  nohup .venv/bin/python stratum-converter.py "$STRATUM_PORT" 127.0.0.1 \
    "$RPC_USER" "$RPC_PASS" "$RPC_PORT" true false true >> /tmp/stratum-mainnet.log 2>&1 &
  sleep 2
  cd "$HNB_ROOT"
fi

if command -v docker >/dev/null 2>&1; then
  if docker ps -a --format '{{.Names}}' | grep -qx "$MINER_CONTAINER"; then
    docker rm -f "$MINER_CONTAINER" >/dev/null 2>&1 || true
  fi
  docker run -d --name "$MINER_CONTAINER" --network host --gpus all \
    "$MINER_IMAGE" \
    -P "stratum+tcp://${MINING_ADDR}.${MINER_POOL_USER}@127.0.0.1:${STRATUM_PORT}"
fi

echo "miningaddress: $MINING_ADDR"
echo "ravend:  $(pgrep -af 'ravend.*mainnet' || echo 'not running')"
echo "stratum: $(pgrep -af "stratum-converter.py ${STRATUM_PORT}" | head -1 || echo 'not running')"
echo "height:  $($CLI -conf="$CONF" getblockcount)"
ss -tlnp 2>/dev/null | grep ":${STRATUM_PORT} " || true
