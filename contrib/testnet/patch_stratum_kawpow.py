#!/usr/bin/env python3
"""Patch ravencoin-stratum-proxy for KawPow (pprpcheader / pprpcsb)."""
from pathlib import Path
import sys
GBT_OLD = '    data = {"jsonrpc": "2.0", "id": "0", "method": "getblocktemplate", "params": []}'
GBT_NEW = '    data = {"jsonrpc": "2.0", "id": "0", "method": "getblocktemplate", "params": [{"rules": ["segwit"]}]}'
KAWPOW_MARKER = '            if "pprpcheader" in json_obj["result"]:'
KAWPOW_BLOCK = '''            if "pprpcheader" in json_obj["result"]:
                result = json_obj["result"]
                height_int = result["height"]
                header_hash = result["pprpcheader"]
                new_work = state.height != height_int or state.headerHash != header_hash
                state.bits = result["bits"]
                state.target = result["target"]
                ts = int(time.time())
                if state.height == -1 or height_int > state.height:
                    if not state.seedHash:
                        seed_hash = bytes(32)
                        for _ in range(height_int // KAWPOW_EPOCH_LENGTH):
                            k = sha3.keccak_256()
                            k.update(seed_hash)
                            seed_hash = k.digest()
                        state.seedHash = seed_hash
                    elif height_int // KAWPOW_EPOCH_LENGTH > state.height // KAWPOW_EPOCH_LENGTH:
                        k = sha3.keccak_256()
                        k.update(state.seedHash)
                        state.seedHash = k.digest()
                if new_work:
                    original_state = deepcopy(state)
                    state.headerHash = header_hash
                    state.height = height_int
                    state.timestamp = ts
                    state.job_counter += 1
                    add_old_state_to_queue(old_states, original_state, drop_after)
                    for session in state.all_sessions:
                        await session.send_notification("mining.set_target", (state.target,))
                        await session.send_notification(
                            "mining.notify",
                            (
                                hex(state.job_counter)[2:],
                                state.headerHash,
                                state.seedHash.hex(),
                                state.target,
                                True,
                                state.height,
                                state.bits,
                            ),
                        )
                    for session in state.new_sessions:
                        state.all_sessions.add(session)
                        await session.send_notification("mining.set_target", (state.target,))
                        await session.send_notification(
                            "mining.notify",
                            (
                                hex(state.job_counter)[2:],
                                state.headerHash,
                                state.seedHash.hex(),
                                state.target,
                                True,
                                state.height,
                                state.bits,
                            ),
                        )
                    state.new_sessions.clear()
                else:
                    state.headerHash = header_hash
                    state.height = height_int
                return
'''
SUBMIT_OLD = '''        block_hex = state.build_block(nonce_hex, mixhash_hex)
        data = {
            "jsonrpc": "2.0",
            "id": "0",
            "method": "submitblock",
            "params": [block_hex],
        }'''
SUBMIT_NEW = '''        # KawPow: node expects pprpcsb with header hash from getblocktemplate
        data = {
            "jsonrpc": "2.0",
            "id": "0",
            "method": "pprpcsb",
            "params": [state.headerHash, mixhash_hex, nonce_hex],
        }'''
RESULT_OLD = '''                if result not in (
                    None,
                    "inconclusive",
                    "duplicate",
                    "duplicate-inconclusive",
                    "inconclusive-not-best-prevblk",
                ):
                    raise RPCError(20, json_resp["result"])'''
RESULT_NEW = '''                if result not in (
                    None,
                    True,
                    "inconclusive",
                    "duplicate",
                    "duplicate-inconclusive",
                    "inconclusive-not-best-prevblk",
                ):
                    raise RPCError(20, json_resp["result"])'''
HEIGHT_OLD = '''        # Get height from block hex
        block_height = int.from_bytes(
            bytes.fromhex(
                block_hex[(4 + 32 + 32 + 4 + 4) * 2 : (4 + 32 + 32 + 4 + 4 + 4) * 2]
            ),
            "little",
            signed=False,
        )'''
HEIGHT_NEW = '''        block_height = state.height'''
def main() -> None:
    if len(sys.argv) != 2:
        print(f"Usage: {sys.argv[0]} /path/to/stratum-converter.py", file=sys.stderr)
        sys.exit(1)
    path = Path(sys.argv[1])
    text = path.read_text()
    if 'method": "pprpcsb"' in text and KAWPOW_MARKER.strip() in text:
        print("already patched")
        return
    if GBT_OLD not in text:
        raise SystemExit("Could not find getblocktemplate line to patch")
    text = text.replace(GBT_OLD, GBT_NEW, 1)
    anchor = '                version_int: int = json_obj["result"]["version"]'
    if anchor not in text:
        raise SystemExit("Could not find stateUpdater parse anchor")
    if KAWPOW_MARKER.strip() not in text:
        text = text.replace(anchor, KAWPOW_BLOCK + anchor, 1)
    if SUBMIT_OLD not in text:
        raise SystemExit("Could not find submitblock block to patch")
    text = text.replace(SUBMIT_OLD, SUBMIT_NEW, 1)
    if RESULT_OLD not in text:
        raise SystemExit("Could not find submit result check to patch")
    text = text.replace(RESULT_OLD, RESULT_NEW, 1)
    if HEIGHT_OLD not in text:
        raise SystemExit("Could not find block height parse to patch")
    text = text.replace(HEIGHT_OLD, HEIGHT_NEW, 1)
    path.write_text(text)
    print(f"patched {path}")
if __name__ == "__main__":
    main()
