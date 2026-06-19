<p align="center">
  <img src="../../doc/img/hbc-logo.png" alt="HookersAndBlowCoin (HBC)" width="200">
</p>

# HNB testnet — node and solo mining

Independent testnet (not Raven-compatible).

| Setting | Value |
|---------|-------|
| P2P port | **28890** |
| RPC port | **28889** |
| Data dir | `~/.raven/testnet` |
| Genesis hash | `0000001e7af0fe066e9f6821066e3db8db681137bd192a41bb799a55b4c883d0` |
| Block algorithm | KawPow (block 1+) |

## 1. Build

```bash
cd HookersAndBlowCoin
./autogen.sh
./configure --without-gui
make -j$(nproc)
```

Wallet support requires Berkeley DB (`libdb-dev` / `db4.8` per `doc/build-ubuntu.md`).

## 2. `raven.conf` (testnet)

`~/.raven/raven.conf`:

```
testnet=1
server=1
bypassdownload=1
listen=1
rpcuser=hnb
rpcpassword=hnb_dev_password_change_me
```

## 3. Start order (important)

Always start in this order:

1. **`ravend`** — RPC must be up before the proxy
2. **Stratum proxy** — listens on `:3333`, talks to RPC `:28889`
3. **`kawpowminer`** — connects to `127.0.0.1:3333`

Quick start:

```bash
./contrib/testnet/start-mining.sh
```

Or manually:

```bash
./src/ravend -testnet -daemon -bypassdownload -miningaddress=$(./src/raven-cli -testnet getnewaddress)

cd ~/ravencoin-stratum-proxy
.venv/bin/python stratum-converter.py 3333 127.0.0.1 hnb hnb_dev_password_change_me 28889 true true

docker run --rm -d --name kawpowminer --network host --gpus all \
  kawpowminer-5090-docker-kawpowminer \
  -P stratum+tcp://USER.worker@127.0.0.1:3333
```

If the miner logs `Connection refused` on `:3333`, the proxy is down — restart it (step 2), then `docker restart kawpowminer`.

## 4. Stratum proxy (KawPow)

Stock [ravencoin-stratum-proxy](https://github.com/RavenCommunity/ravencoin-stratum-proxy) must be patched for KawPow (`pprpcheader` / `pprpcsb`):

```bash
git clone https://github.com/RavenCommunity/ravencoin-stratum-proxy.git ~/ravencoin-stratum-proxy
cd ~/ravencoin-stratum-proxy
python3 -m venv .venv
.venv/bin/pip install aiohttp base58 coincurve pycryptodome requests

python3 /path/to/HookersAndBlowCoin/contrib/testnet/patch_stratum_kawpow.py \
  ~/ravencoin-stratum-proxy/stratum-converter.py
```

Use **`pycryptodome`** for Keccak on Python 3.14+ (`pysha3` often fails to build).

Proxy args: `PORT RPC_HOST RPC_USER RPC_PASS RPC_PORT USE_PPRPC true`

## 5. Smoke tests

```bash
./src/raven-cli -testnet getblockchaininfo
./src/raven-cli -testnet getblockhash 0   # genesis check
./src/raven-cli -testnet getbalance
./src/raven-cli -testnet getnewaddress
./src/raven-cli -testnet sendtoaddress <addr> 10

# Assets (after BIP9 activation on testnet)
./src/raven-cli -testnet issue HNB_TEST 1000
./src/raven-cli -testnet transfer HNB_TEST 100 <addr>
./src/raven-cli -testnet listmyassets
```

Coinbase rewards need **100 confirmations** before spend. Asset issue costs **500 HNB** (burned).

## 6. Fixed seeds

Add known testnet nodes to `contrib/seeds/nodes_test.txt` (with explicit `:28890`), then:

```bash
python3 contrib/seeds/generate-seeds.py contrib/seeds > src/chainparamsseeds.h
```

Rebuild after updating seeds.

## 7. systemd (optional)

User units in `contrib/testnet/systemd/` — install to `~/.config/systemd/user/`, then:

```bash
systemctl --user enable --now hnbcoin-ravend.service hnbcoin-stratum.service
loginctl enable-linger $USER   # keep services running after logout
```

Start the GPU miner separately (`docker start kawpowminer`).
