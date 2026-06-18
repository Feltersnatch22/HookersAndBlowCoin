#!/usr/bin/env bash
# Start HNB testnet node, KawPow stratum proxy, and kawpowminer (Docker).
set -euo pipefail

HNB_ROOT="${HNB_ROOT:-$HOME/code/hnbcoin/HookersAndBlowCoin}"
PROXY_DIR="${PROXY_DIR:-$HOME/ravencoin-stratum-proxy}"
MINING_ADDR="${MINING_ADDR:-}"
RPC_USER="${RPC_USER:-hnb}"
RPC_PASS="${RPC_PASS:-hnb_dev_password_change_me}"
STRATUM_PORT="${STRATUM_PORT:-3333}"
RPC_PORT="${RPC_PORT:-28889}"
MINER_CONTAINER="${MINER_CONTAINER:-kawpowminer}"
MINER_IMAGE="${MINER_IMAGE:-kawpowminer-5090-docker-kawpowminer}"
MINER_POOL_USER="${MINER_POOL_USER:-worker}"

cd "$HNB_ROOT"

if ! pgrep -f '[/]src/ravend -testnet' >/dev/null && ! pgrep -f '[/]ravend -testnet' >/dev/null; then
  if [[ -z "$MINING_ADDR" ]]; then
    echo "Starting ravend without -miningaddress (set MINING_ADDR to mine coinbase to a fixed address)"
    ./src/ravend -testnet -daemon -bypassdownload
  else
    ./src/ravend -testnet -daemon -bypassdownload -miningaddress="$MINING_ADDR"
  fi
  sleep 3
fi

if ! ./src/raven-cli -testnet getblockcount >/dev/null 2>&1; then
  echo "ravend RPC not responding on testnet (port $RPC_PORT)" >&2
  exit 1
fi

if ! pgrep -f '[s]tratum-converter.py' >/dev/null; then
  if [[ ! -f "$PROXY_DIR/.venv/bin/python" ]]; then
    echo "Missing $PROXY_DIR/.venv — see contrib/testnet/README.md" >&2
    exit 1
  fi
  cd "$PROXY_DIR"
  nohup .venv/bin/python stratum-converter.py "$STRATUM_PORT" 127.0.0.1 \
    "$RPC_USER" "$RPC_PASS" "$RPC_PORT" true true >> /tmp/stratum.log 2>&1 &
  sleep 2
  cd "$HNB_ROOT"
fi

if command -v docker >/dev/null 2>&1; then
  if docker ps -a --format '{{.Names}}' | grep -qx "$MINER_CONTAINER"; then
    docker start "$MINER_CONTAINER" 2>/dev/null || docker restart "$MINER_CONTAINER"
  else
    POOL_USER="${MINING_ADDR:-$MINER_POOL_USER}"
    docker run -d --name "$MINER_CONTAINER" --network host --gpus all \
      "$MINER_IMAGE" \
      -P "stratum+tcp://${POOL_USER}.${MINER_POOL_USER}@127.0.0.1:${STRATUM_PORT}"
  fi
fi

echo "ravend:  $(pgrep -a ravend | grep testnet || echo 'not running')"
echo "stratum: $(pgrep -af stratum-converter | head -1 || echo 'not running')"
echo "height:  $(./src/raven-cli -testnet getblockcount)"
ss -tlnp 2>/dev/null | grep ":${STRATUM_PORT} " || true
