<p align="center">
  <img src="https://raw.githubusercontent.com/Feltersnatch22/HookersAndBlowCoin/release-v4.6.1/doc/img/hbc-logo.png" alt="HookersAndBlowCoin (HBC)" width="200">
</p>

# HookersAndBlowCoin v4.6.1 — Mainnet launch

First public release for the independent HNB chain.

## Downloads

| Platform | File |
|----------|------|
| Linux x86_64 (headless) | `raven-*-x86_64-linux-gnu.tar.gz` |
| Windows x64 (headless) | `raven-*-win64.zip` |

These packages include `ravend` and `raven-cli` only (no Qt GUI wallet).

Build from source: [doc/build-ubuntu.md](https://github.com/Feltersnatch22/HookersAndBlowCoin/blob/release-v4.6.1/doc/build-ubuntu.md)

## Network (mainnet)

| Setting | Value |
|---------|-------|
| P2P | **28888** |
| RPC | **28887** (local only) |
| Genesis | `0000005bc2484f740d4c3087211e3aa44d33e7691c9dfdf099b823f735f0be2b` |

## Quick start (Linux)

```bash
tar xzf linux-*.tar.gz   # name from CI artifact
./ravend -daemon -bypassdownload
./raven-cli getblockhash 0
```

Expected genesis hash above. See `contrib/mainnet/README.md` for seed nodes and mining setup.

## Testnet

Separate chain — port **28890**. Guide: `contrib/testnet/README.md`.

## Checksums

SHA256 checksums are included in each platform package when produced by CI (`06-package.sh`).
