# HNB mobile wallets (Android & iOS)

Fork the official Raven SPV wallets and apply HNB chain parameters from [../hnb-network.json](../hnb-network.json).

## Upstream

| Platform | Repository |
|----------|------------|
| Android | https://github.com/RavenProject/ravenwallet-android |
| iOS | https://github.com/RavenProject/ravenwallet-ios |

Suggested fork names: `Feltersnatch22/hnb-wallet-android`, `Feltersnatch22/hnb-wallet-ios`.

## Checklist (both platforms)

1. **Ports** — mainnet P2P `28888`, RPC `28887`; testnet `28890` / `28889`
2. **Magic / message start** — mainnet `a1 b2 c3 d4`; testnet `48 4e 42 54` (`HNBT`)
3. **Address versions** — pubkey `40` / `111`, script `85` / `196`, WIF `200` / `239`
4. **BIP44** — coin type **1919** (mainnet), path `m/44'/1919'/0'/0/0`
5. **Genesis** — verify block 0 hash matches `hnb-network.json`
6. **Seeds** — `contrib/seeds/nodes_main.txt`, `nodes_test.txt`
7. **Branding** — `doc/img/hbc-logo.png`, name “HookersAndBlow” / ticker HNB

## Android

Search the fork for `RavenMainNetParams`, `RavenParams`, or `chainparams` packages. Replace:

- `PUBKEY_ADDRESS_PREFIX` → `40`
- `SCRIPT_ADDRESS_PREFIX` → `85`
- `PORT` → `28888`
- `packetMagic` → bytes for `0xa1, 0xb2, 0xc3, 0xd4`
- `bip44CoinType` → `1919`

See [android-chainparams.snippet.java](android-chainparams.snippet.java) for a reference block.

Build: Android Studio, `assembleDebug`, point at testnet first.

## iOS

Search for `BRChainParams`, `Raven`, or network configuration in the Xcode project. Apply the same constants as Android.

See [ios-chainparams.snippet.swift](ios-chainparams.snippet.swift).

## Alternative: Flutter (Moontree)

One codebase for Android, iOS, and Web: https://github.com/moontreeapp/moontree — add HNB as a custom UTXO chain in `wallet_utils`.

## Smoke test

1. Install testnet build
2. Confirm genesis hash on connect
3. Receive from local miner / faucet
4. Send 1000 HNB
5. After assets activate on testnet (~block 863): issue + transfer test asset
