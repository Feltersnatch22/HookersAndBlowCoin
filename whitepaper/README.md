# Hookers and Blow Coin (HNB) Whitepaper

**Version 1.1 · Testnet · June 2026**

A Ravencoin fork engineered for the decentralized creator and underground economy. Asset issuance, royalty enforcement, and programmable ownership — all for less than a cent per transaction.

| | |
|---|---|
| **Ticker** | HNB |
| **Algorithm** | KawPoW (GPU mining) |
| **Block time** | ~1 minute |
| **Hard cap** | 420,690,000 HNB |
| **Website** | https://hookersandblow.xyz |
| **Whitepaper (web)** | https://hookersandblow.xyz/whitepaper |
| **Repository** | https://github.com/Feltersnatch22/HookersAndBlowCoin |

---

## Abstract

Hookers and Blow Coin (HNB) is a UTXO-based asset protocol and proof-of-work cryptocurrency designed for the creator, nightlife, and underground economies — markets where existing platforms extract excessive rents, censor content, and strip creators of ownership over their work and audience.

Built as a targeted fork of Ravencoin, HNB adds lightweight contract primitives — royalty enforcement, burn-to-claim, time-locked vesting, and soulbound assets — without adopting the complexity or cost structure of full EVM chains. The result is a chain where issuing a VIP pass, splitting event revenue, or gating content costs fractions of a cent and requires no developer.

**Own Your Hustle.** HNB exists to make the underground economy programmable and self-sovereign. No platform to ban you. No gas fee to kill your margin. No VC allocation to dump on retail.

---

## 1. Why HNB — Not the Alternatives

Every chain claims to solve creator economy problems. Here is why the existing options fail this market specifically:

| Competitor | What they do well | Why they fail this market | Verdict |
|---|---|---|---|
| Ethereum / Base | Smart contracts, liquidity, ecosystem | Gas fees destroy micro-transactions. $10+ to mint an NFT kills creator margins. | Too expensive |
| Solana | Fast, cheap, large ecosystem | VC-heavy launch, outages, centralized validators. Not censorship-resistant for adult content. | Too corporate |
| DOGE / PEPE | Culture and community | Zero utility. No asset issuance. No way to build real products on top. | Culture, no infrastructure |
| Ravencoin (RVN) | Asset protocol, fair PoW launch | Stagnant development, no community direction, no contract layer. | HNB is what RVN should have become |
| Flow / Tezos NFT chains | NFT-native, royalties baked in | Enterprise-focused, minimal retail culture, high barrier to participate. | Built for brands, not builders |

**HNB's moat:** UTXO asset issuance at sub-cent fees + PoW fair launch + a community built around creators, nightlife, and degen culture. Ravencoin had the tech but never found the community. HNB finds both.

---

## 2. Technical Foundation

HNB implements ownership primitives as targeted protocol extensions on top of the Ravencoin UTXO model — not a full EVM. Each primitive is designed to cover a specific creator economy use case with minimal protocol complexity and a small, auditable attack surface.

### Asset Protocol (UTXO-native)

- Fungible tokens, NFTs, unique assets, sub-assets — all native to the UTXO model
- On-chain metadata via IPFS CID in OP_RETURN
- Divisibility 0–8 decimals, set at mint
- Reissuable or fixed supply — issuer's choice at creation

### KawPoW Proof-of-Work

- ASIC-resistant DAG algorithm — GPU mining only
- 4 GB+ VRAM minimum — accessible to consumer hardware
- ~1 minute target block time
- Dark Gravity Wave (DGW) difficulty retarget

### Security Model

- No reentrancy — UTXO inputs spent atomically
- No approval exploits — assets require direct ownership
- Script-based — limited opcodes = smaller attack surface
- SPV-compatible lightweight client verification

### Why Not EVM?

EVM gives you Turing-complete contracts but also reentrancy attacks, approval drains, and $10+ gas for simple operations. A creator selling 200 VIP passes at $5 each cannot absorb those costs. HNB's UTXO script extensions cover 90% of use cases at a fraction of the cost.

---

## 3. Contract Primitives

Six targeted ownership primitives — no Turing-complete overhead. Each covers a specific real-world use case.

### Timelock Vesting *(Phase 1/2 · High feasibility)*

**Mechanism:** CheckLockTimeVerify (CLTV) inherited from Bitcoin via Ravencoin. Coins or assets are locked in P2SH with a script requiring block height > N to spend. Fully enforced by consensus.

**Use case:** Team allocation: 10% locked in CLTV. Unlocks 20%/year starting at mainnet block 525,600. Verifiable by anyone on the explorer.

### Multi-Sig Escrow *(Phase 1/2 · High feasibility)*

**Mechanism:** Standard P2SH multi-sig (N-of-M). Two parties deposit to escrow address; release requires M signatures. Arbiter key can be a trusted third party or a DAO key.

**Use case:** Promoter books venue: 50% deposit locked in 2-of-3 (promoter, venue, arbiter). Funds release to venue after event, or return to promoter if event cancels.

### Burn-to-Claim *(Phase 2 · High feasibility)*

**Mechanism:** Atomic transaction spends (burns) asset X as input and creates asset Y as output. Both settle in the same block — no escrow, no counterparty risk.

**Use case:** Venue issues `CLUB/TICKET` (1000 supply). Each ticket can be burned to claim `CLUB/PROOF_OF_ATTENDANCE` (soulbound) after the event date.

### Soulbound Assets *(Phase 2 · High feasibility)*

**Mechanism:** Protocol-level flag set at asset issuance marks asset as non-transferable. Consensus rejects any tx attempting to move a soulbound asset. Burn is still permitted.

**Use case:** Event attendance badge, membership tier, verified creator status — issued once, lives permanently in that wallet, provable on-chain.

### Royalty Enforcement *(Phase 3 · Medium complexity)*

**Mechanism:** Transaction script validates that N% of HNB in the tx routes to creator address embedded in asset metadata. Enforced at consensus — any tx missing the royalty payment is invalid.

**Use case:** Creator mints `ARTIST/PRINT` with 10% royalty. Every resale on-chain automatically sends 10% to creator wallet.

### Revenue Share Pass *(Phase 3–4 · Complex)*

**Mechanism (v1):** Snapshot-based: issuer takes on-chain snapshot of token holders at a defined block height, then runs a distribution tx paying each holder proportionally.

**Use case:** Creator issues 1000 `CREATOR/REVENUE_PASS`. Monthly snapshot distributes 70% of tip revenue to all pass holders proportionally.

---

## 4. Use Cases

HNB targets four overlapping markets that share a common problem: they need programmable ownership without corporate intermediaries or enterprise-level costs.

### Creator Economy

Issue VIP passes, content gates, and tip tokens in minutes. Royalties enforced by protocol — every resale pays you automatically. No platform taking 20%. No account to ban.

- Creator VIP Pass — NFT + revenue share, transferable or soulbound
- Content Drop Token — burn-to-unlock pay-per-view
- Tip Token — branded fungible token redeemable for perks

### Nightlife & Events

Tickets that can't be faked. VIP passes that enforce themselves. Revenue splits that execute the moment the transaction clears.

- Digital Ticket NFT — timed validity, on-chain redemption
- VIP Table Pass — secondary market with venue royalty
- Promoter Revenue Share — multi-sig door split

### Meme & Degen Economy

Issue a community token in two minutes. Fixed supply, provable on-chain, no dev needed.

- Community Asset — meme collection with provable supply
- Prediction Market Token — burn-to-claim resolution
- Degen DAO Pass — governance for community treasury

### Real-World Asset Lite

Permanent provenance tracking. Fractional ownership. Asset transfer equals ownership handoff.

- Memorabilia Provenance — IPFS metadata on-chain forever
- Fractional Experience — studio session, luxury trip
- Collectible Authentication — transfer = handoff

---

## 5. Tokenomics

| Parameter | Value |
|---|---|
| Hard cap supply | 420,690,000 HNB |
| Starting block reward | 60 HNB |
| Halving interval | ~4 years |
| Full emission | ~14 years |

### Supply Allocation

| Allocation | Share | Amount |
|---|---|---|
| Mining Rewards (PoW) | 60% | 252,414,000 HNB |
| Liquidity Bootstrap | 20% | 84,138,000 HNB |
| Dev & Team (Vested) | 10% | 42,069,000 HNB |
| Marketing & Community | 10% | 42,069,000 HNB |

Mining rewards are distributed via fair PoW over ~14 years. No premine, no founder allocation in coinbase. Team allocation is subject to 3-year linear vest with 6-month cliff, enforced via CLTV timelock scripts.

### Emission Schedule

| Epoch | Period | Block Reward | Blocks | HNB Emitted | Cumulative |
|---|---|---|---|---|---|
| 1 | Year 1–4 | 60 HNB | 2,100,000 | 126,000,000 | 50% |
| 2 | Year 4–8 | 30 HNB | 2,100,000 | 63,000,000 | 75% |
| 3 | Year 8–12 | 15 HNB | 2,100,000 | 31,500,000 | 87.5% |
| 4 | Year 12–16 | 7.5 HNB | 2,100,000 | 15,750,000 | 93.75% |
| Tail | Year 16+ | ↓ | ∞ | 16,164,000 | 100% |

### Asset Creation Burns (Deflationary)

| Asset Type | HNB Burned | Example |
|---|---|---|
| Main Asset | 500 HNB | `NIGHTCLUB` |
| Sub-Asset | 100 HNB | `NIGHTCLUB/VIP_PASS` |
| Unique Asset (NFT) | 5 HNB | `NIGHTCLUB/VIP_PASS#0001` |
| HNB Transfer | ~0.01 HNB | Send / receive |

---

## 6. Roadmap

### Phase 1 — Testnet *(Live · Q2 2026)*

- Asset issuance & transfer
- Qt wallet (Windows + Linux)
- KawPoW GPU mining + stratum
- Block explorer
- Dedicated seed node VPS

### Phase 2 — Mainnet Launch *(Q3 2026)*

- Mainnet genesis
- Asset marketplace v1
- Creator dashboard
- Mobile wallet
- CEX/DEX listings

### Phase 3 — Ecosystem Growth *(Q4 2026)*

- Royalty enforcement contracts
- Event ticket platform
- Revenue share passes
- API for third-party apps
- Community grants program

### Phase 4 — RWA & DAO *(Q1 2027)*

- Real-world asset tokenization
- On-chain DAO governance
- Community treasury
- Cross-chain bridge research
- Enterprise partnerships

---

## 7. Risks & Disclaimers

**HNB is a high-risk experimental cryptocurrency.** It is in active testnet. Mainnet has not launched. Do not invest more than you can afford to lose completely. This document is not financial advice.

| Risk | Description |
|---|---|
| Market risk | Cryptocurrency valuations can reach zero. DYOR. |
| Technical risk | Contract primitives are unaudited pre-mainnet. Get an independent audit before production use. |
| Regulatory risk | Content-adjacent projects face uncertain treatment in many jurisdictions. Know your local laws. |
| Mining centralization | KawPoW ASIC resistance mitigates but does not eliminate 51% attack risk if hash rate concentrates. |
| Liquidity risk | Early-stage chain. Exit liquidity may be limited at launch. |

*For informational purposes only. Not financial advice. Adult-themed project — participation subject to applicable local laws. © 2026 Hookers and Blow Coin.*

---

## Acknowledgements

HNB is built on Ravencoin and Bitcoin. Thank you to the open-source developers whose work made this project possible.
