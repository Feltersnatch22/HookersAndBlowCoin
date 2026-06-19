# HNB wallets — desktop, web, and mobile

HookersAndBlowCoin ships a full **Qt desktop wallet** in this repo (`raven-qt`). **Web** and **mobile** wallets are separate apps that must be forked and pointed at HNB network constants (below).

Current CI releases are **headless** (`ravend` + `raven-cli` only) because cross-compiling Qt 5.12 in `depends/` fails on Ubuntu 22.04. Native desktop builds use system Qt 5 — see [build-desktop-qt.sh](build-desktop-qt.sh).

## Network constants (wallet developers)

| | Mainnet | Testnet |
|---|---------|---------|
| P2P | **28888** | **28890** |
| RPC | **28887** | **28889** |
| Message start | `a1 b2 c3 d4` | (see `chainparams.cpp`) |
| Pubkey address prefix | **40** (`H...`) | **111** (`m...`) |
| BIP44 coin type (`nExtCoinType`) | **1919** | **1** |
| Default HD path | `m/44'/1919'/0'/0/0` | `m/44'/1'/0'/0/0` |
| Genesis hash | `0000005bc2484f740d4c3087211e3aa44d33e7691c9dfdf099b823f735f0be2b` | `0000001e7af0fe066e9f6821066e3db8db681137bd192a41bb799a55b4c883d0` |

Assets, restricted assets, and messaging use the same RPC surface as RavenCoin — point clients at your node.

## Desktop (in this repo)

| Binary | Description |
|--------|-------------|
| `raven-qt` | Qt GUI — send/receive HNB, assets, messaging UI |
| `ravend` | Headless node (already in releases) |
| `raven-cli` | RPC CLI (already in releases) |

**Build (Linux, system Qt):**

```bash
./contrib/wallets/build-desktop-qt.sh
# output: src/qt/raven-qt
```

**Windows:** build with Qt 5.12+ and MSVC or cross-compile per `doc/build-windows.md` (GUI requires full `depends` Qt — not in current CI).

## Mobile (fork required)

Official Raven wallets are open source (MIT). Fork and replace chain params, seeds, ports, and BIP44 type **1919**:

| Platform | Upstream | Notes |
|----------|----------|--------|
| Android | [RavenProject/ravenwallet-android](https://github.com/RavenProject/ravenwallet-android) | SPV, BIP39, assets |
| iOS | [RavenProject/ravenwallet-ios](https://github.com/RavenProject/ravenwallet-ios) | SPV, assets |

**HNB-specific changes in a fork:**

1. `chainparams` / magic bytes / default port **28888** (mainnet) or **28890** (testnet)
2. Address version bytes (40 / 111)
3. BIP44 `coin_type` → **1919** (mainnet)
4. Default seed nodes from `contrib/seeds/nodes_main.txt` / `nodes_test.txt`
5. Branding (name, icons) — use `doc/img/hbc-logo.png`
6. Asset RPC compatibility (already Raven-forked in core)

**Alternative:** [moontreeapp/moontree](https://github.com/moontreeapp/moontree) (Flutter, Android/iOS/Web) — multi-chain; add HNB as a custom UTXO chain via `wallet_utils`.

Suggested repo names: `HookersAndBlowCoin/wallet-android`, `wallet-ios`, or one `wallet-flutter` monorepo.

## Web (new project)

There is no web wallet in this core repo. Practical options:

| Approach | Pros | Cons |
|----------|------|------|
| **Flutter Web** (Moontree fork) | Same code as mobile, BIP39 in browser | Large bundle; needs ElectrumX or SPV bridge |
| **Thin RPC client** | Fast to prototype | Keys in browser or custodial backend — not for production |
| **ElectrumX + Electrum-style JS** | Standard model | Must run HNB ElectrumX server (not shipped yet) |

Minimum viable web wallet:

1. Client-side BIP39 + signing (WASM or JS port of asset tx building)
2. Public `ravend` RPC **or** ElectrumX with HNB headers
3. Host static SPA (GitHub Pages / Cloudflare)

Track as separate repo: `HookersAndBlowCoin/wallet-web`.

## Recommended rollout

1. **Now** — Ship headless binaries (done in v4.6.1); document `raven-qt` native build
2. **Next** — CI job `linux-qt` (system Qt) + attach `raven-qt` to releases
3. **Parallel** — Fork Android/iOS wallets → testnet smoke → mainnet
4. **Then** — Flutter or Electrum-based web wallet

## Smoke test (any wallet)

1. Connect to testnet (port **28890**)
2. Verify genesis hash matches table above
3. Receive testnet HNB from faucet/miner
4. Send 1000 HNB
5. After assets activate (~block 863 on testnet): `issue` + `transfer` smoke asset
