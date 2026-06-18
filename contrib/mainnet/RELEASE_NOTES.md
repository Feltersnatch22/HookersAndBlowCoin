# HookersAndBlowCoin v4.6.1 — Mainnet launch

## Downloads

Pre-built binaries: https://github.com/Feltersnatch22/HookersAndBlowCoin/releases

| Platform | Artifact |
|----------|----------|
| Linux x86_64 | `linux` CI artifact |
| Windows | `windows` CI artifact |
| Linux ARM64 | `aarch64` CI artifact |

Build from source: see `doc/build-ubuntu.md`.

## Network

- **P2P:** 28888
- **RPC:** 28887 (local only)
- **Genesis:** `0000005bc2484f740d4c3087211e3aa44d33e7691c9dfdf099b823f735f0be2b`

## Quick start

```bash
tar xzf hnbcoin-*-linux64.tar.gz
./ravend -daemon -bypassdownload
./raven-cli getblockhash 0
```

## Seed nodes

See `contrib/seeds/nodes_main.txt` for fixed seeds baked into this release.

## Testnet

Testnet guide: `contrib/testnet/README.md` (port 28890, separate chain).
