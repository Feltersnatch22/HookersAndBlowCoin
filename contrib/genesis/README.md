# Genesis block mining

HookersAndBlowCoin uses X16R for the genesis block. Use `mine_genesis.py` to regenerate
parameters if the coinbase timestamp or network params change.

## Prerequisites (WSL/Linux)

```bash
git clone https://github.com/brian112358/x16r_hash.git /tmp/x16r_hash
cd /tmp/x16r_hash && python3 setup.py build_ext --inplace
```

## Mine mainnet

```bash
PYTHONPATH=/tmp/x16r_hash python3 contrib/genesis/mine_genesis.py \
  -z "HookersAndBlowCoin genesis 18/Jun/2026 fair launch peer-to-peer asset network" \
  --time 1750251600 -b 0x1e00ffff -v 4
```

Mined values are recorded in `out/mainnet_genesis.txt` and wired into `src/chainparams.cpp`.

## Network ports

| Network | P2P   | RPC   |
|---------|-------|-------|
| Mainnet | 28888 | 28887 |
| Testnet | 28890 | 28889 |
| Regtest | 18444 | 18443 |
