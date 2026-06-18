# HookersAndBlowCoin mainnet launch prep

Independent mainnet (not Raven-compatible). Testnet validation is complete; this doc covers going live on **main**.

## Network constants

| Setting | Value |
|---------|-------|
| P2P port | **28888** |
| RPC port | **28887** |
| Data dir | `~/.raven/` |
| Genesis hash | `0000005bc2484f740d4c3087211e3aa44d33e7691c9dfdf099b823f735f0be2b` |
| Genesis time (in chain) | **2025-06-18 13:00:00 UTC** (`1750251600`) |
| Block 1+ PoW | KawPow (activation time already passed if starting in 2026) |
| DGW | block **180** |
| Coinbase maturity | **100** blocks |
| Asset issue burn | **500 HNB** |

Message start: `a1 b2 c3 d4` · Addresses: `R...` / `r...`

## Genesis countdown

```bash
./contrib/mainnet/genesis-countdown.sh
```

Shows genesis/KawPow timestamps from `chainparams.cpp`, time until/since each, and recommended pre-launch checklist status.

**Note:** The embedded genesis **time** is a fixed chain parameter (mined with nonce `17233052`). “Launch” is when seed nodes and miners start on mainnet — not when the genesis block was computed offline.

## Pre-launch checklist

### Seeds (required)

1. Run at least **two** reachable nodes with `listen=1` on port **28888**.
2. Add their public IPs to `contrib/seeds/nodes_main.txt` (always include `:28888`).
3. Regenerate and commit:

```bash
python3 contrib/seeds/generate-seeds.py contrib/seeds > src/chainparamsseeds.h
```

4. Rebuild and redeploy **every** seed node with the new binary before announcing launch.

Current seeds point at the dev server (Tailscale + LAN). Replace/add production hosts before public launch.

### Binaries (required)

GitHub Actions builds on **`release*`** branches (see `.github/workflows/build-raven.yml`):

```bash
git checkout -b release-v4.6.1
git push -u origin release-v4.6.1
```

When CI finishes, download artifacts from the Actions run (linux, windows, arm, etc.) and attach them to a GitHub Release:

```bash
gh release create v4.6.1 --title "HookersAndBlowCoin v4.6.1" --notes-file contrib/mainnet/RELEASE_NOTES.md
```

Or upload manually at: https://github.com/Feltersnatch22/HookersAndBlowCoin/releases

Ship at minimum: **Linux x86_64** (`ravend`, `raven-cli`), **Windows** zip, and document build-from-source in `doc/build-ubuntu.md`.

### Seed node config

Copy `contrib/mainnet/raven.conf.example` to `~/.raven/raven.conf`. Set strong `rpcpassword`. Open firewall **28888/tcp** (P2P only; keep RPC off the public internet).

Start mainnet:

```bash
./src/ravend -daemon -bypassdownload
./src/raven-cli getblockchaininfo
./src/raven-cli getblockhash 0   # must match genesis hash above
```

Optional user service: `contrib/mainnet/systemd/hnbcoin-ravend-mainnet.service`

### Mining at launch

Mainnet uses **KawPow** from the first minable blocks (wall-clock past `nKAWPOWActivationTime`). Use the same patched stratum proxy as testnet, but RPC port **28887** and mainnet datadir.

```bash
.venv/bin/python stratum-converter.py 3333 127.0.0.1 hnb YOUR_RPC_PASS 28887 true true
```

Set `-miningaddress=` to a mainnet wallet address before/at launch if solo mining from `ravend`.

### Post-launch smoke test

```bash
./src/raven-cli getblockcount
./src/raven-cli getbalance
./src/raven-cli sendtoaddress <addr> 1
# After ~2016 blocks with version-bit signaling:
./src/raven-cli issue LAUNCH 1000000
```

### Optional before announce

- [ ] Block explorer / API
- [ ] Pool software (stratum proxy or public pool)
- [ ] Website + wallet download links → GitHub Releases
- [ ] Discord/Telegram with seed IPs for manual `-addnode`

## Changing launch date

If you need a **future** genesis time (fair TGE countdown), you must **re-mine mainnet genesis** and update `src/chainparams.cpp` asserts — that changes the chain identity. Do this only before any mainnet blocks exist. See `contrib/genesis/` and `doc/build-ubuntu.md`.
