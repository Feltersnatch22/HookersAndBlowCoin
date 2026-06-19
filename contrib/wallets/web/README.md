# HNB Web Wallet

Static single-page wallet for **HookersAndBlowCoin**. Keys are derived in the browser (BIP39 + BIP44 coin type **1919** on mainnet).

## Features

- Generate or import 12-word mnemonic
- Derive receive address (`H…` mainnet, `m…` testnet)
- Optional balance check via local `ravend` JSON-RPC

## Run locally

```bash
cd contrib/wallets/web
python3 -m http.server 8080
# open http://127.0.0.1:8080
```

Use only on `localhost` or a host you control. Never enter a mainnet seed on a public site without HTTPS and a trusted deployment.

## RPC (balance)

Point at your node:

| Network | Default RPC |
|---------|-------------|
| Mainnet | `http://127.0.0.1:28887/` |
| Testnet | `http://127.0.0.1:28889/` |

Browsers block cross-origin RPC unless `ravend` sends CORS headers. For production, run a small proxy or use ElectrumX (not shipped in core yet).

## Deploy

Host `index.html`, `app.js`, and `../hnb-network.json` on GitHub Pages, Cloudflare Pages, or any static host. Suggested repo: `HookersAndBlowCoin/wallet-web` mirroring this folder.

## Roadmap

- [ ] Sign & broadcast sends (asset txs need Raven-compatible builder)
- [ ] ElectrumX / SPV instead of full-node RPC
- [ ] WASM build of core signing for assets

Network constants: [../hnb-network.json](../hnb-network.json).
