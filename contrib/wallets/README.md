# HNB wallets — desktop, web, and mobile

HookersAndBlowCoin ships a full **Qt desktop wallet** in this repo (`hnb-qt`). **Web** and **mobile** wallets live under this directory; mobile requires forking upstream Raven wallets with HNB parameters.

CI releases include headless binaries (`hnbd` + `hnb-cli`). A **`linux-qt`** CI job builds the desktop GUI tarball. Windows GUI still needs native Qt or fixed `depends/` Qt cross-build.

Shared network constants: [hnb-network.json](hnb-network.json).

## Network constants (wallet developers)

| | Mainnet | Testnet |
|---|---------|---------|
| P2P | **28888** | **28890** |
| RPC | **28887** | **28889** |
| Message start | `a1 b2 c3 d4` | `48 4e 42 54` (HNBT) |
| Pubkey address prefix | **40** (`H...`) | **111** (`m...`) |
| BIP44 coin type | **1919** | **1** |
| Default HD path | `m/44'/1919'/0'/0/0` | `m/44'/1'/0'/0/0` |
| Genesis hash | `0000005bc2484f740d4c3087211e3aa44d33e7691c9dfdf099b823f735f0be2b` | `0000001e7af0fe066e9f6821066e3db8db681137bd192a41bb799a55b4c883d0` |

## Desktop (in this repo)

| Binary | Description |
|--------|-------------|
| `hnb-qt` | Qt GUI — send/receive HNB, assets, messaging UI |
| `hnbd` | Headless node (in releases) |
| `hnb-cli` | RPC CLI (in releases) |

**Build (Linux, system Qt + BDB 4.8):**

```bash
./contrib/install_db4.sh ../
export BDB_PREFIX=$(pwd)/../db4
./contrib/wallets/build-desktop-qt.sh
# output: src/qt/hnb-qt
```

**CI:** `linux-qt` job produces `raven-*-qt-x86_64-linux-gnu.tar.gz` on release branches.

**Windows:** CI job **Build Windows Qt Wallet** produces `raven-*-win64-qt.zip` (MSYS2 + Qt5). See [build-windows-qt-msys2.md](build-windows-qt-msys2.md).

## Web

Static wallet in [web/](web/) — BIP39 import/generate, address derivation, optional RPC balance.

```bash
cd contrib/wallets/web && python3 -m http.server 8080
```

See [web/README.md](web/README.md). Deploy as static site or mirror to `wallet-web` repo.

## Mobile

Fork Raven Android/iOS wallets with constants from `hnb-network.json`. Templates and checklist: [mobile/README.md](mobile/README.md).

| Platform | Upstream |
|----------|----------|
| Android | [RavenProject/ravenwallet-android](https://github.com/RavenProject/ravenwallet-android) |
| iOS | [RavenProject/ravenwallet-ios](https://github.com/RavenProject/ravenwallet-ios) |

**Alternative:** [moontreeapp/moontree](https://github.com/moontreeapp/moontree) (Flutter — Android, iOS, Web).

## Recommended rollout

1. **Done** — Headless binaries in v4.6.1; wallet docs and web scaffold
2. **CI** — `linux-qt` attaches GUI tarball to releases
3. **Parallel** — Fork Android/iOS → testnet smoke → mainnet
4. **Then** — ElectrumX + send support in web wallet

## Smoke test (any wallet)

1. Connect to testnet (port **28890**)
2. Verify genesis hash matches table above
3. Receive testnet HNB from faucet/miner
4. Send 1000 HNB
5. After assets activate (~block 863 on testnet): `issue` + `transfer` smoke asset
