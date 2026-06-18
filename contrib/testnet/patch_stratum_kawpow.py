#!/usr/bin/env python3
"""Patch ravencoin-stratum-proxy for KawPow (pprpcheader / pprpcsb).

Usage:
  python3 patch_stratum_kawpow.py ~/ravencoin-stratum-proxy/stratum-converter.py
"""
from pathlib import Path
import re
import sys

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


def patch_gbt(text: str) -> tuple[str, bool]:
    if '"rules": ["segwit"]' in text:
        return text, False
    old = 'method": "getblocktemplate", "params": []'
    new = 'method": "getblocktemplate", "params": [{"rules": ["segwit"]}]'
    if old not in text:
        raise SystemExit("Could not find getblocktemplate params to patch")
    return text.replace(old, new, 1), True


def patch_kawpow_updater(text: str) -> tuple[str, bool]:
    marker = 'if "pprpcheader" in json_obj["result"]:'
    if marker in text:
        return text, False
    anchor = 'version_int: int = json_obj["result"]["version"]'
    if anchor not in text:
        raise SystemExit("Could not find stateUpdater version_int anchor")
    return text.replace(anchor, KAWPOW_BLOCK + anchor, 1), True


def patch_submit(text: str) -> tuple[str, bool]:
    if '"method": "pprpcsb"' in text or "'method': 'pprpcsb'" in text:
        return text, False

    if '"method": "submitblock"' not in text:
        raise SystemExit(
            "Could not find submitblock RPC call. Run:\n"
            "  grep -n 'submit\\|pprpc\\|build_block\\|handle_submit' "
            "~/ravencoin-stratum-proxy/stratum-converter.py"
        )

    # Drop unused block_hex assembly when present.
    text, n = re.subn(
        r'^[ \t]*block_hex = state\.build_block\(nonce_hex, mixhash_hex\)\s*\n',
        "",
        text,
        count=1,
        flags=re.MULTILINE,
    )

    text, n2 = re.subn(
        r'"method": "submitblock",\s*\n\s*"params": \[block_hex\],',
        '"method": "pprpcsb",\n            "params": [state.headerHash, mixhash_hex, nonce_hex],',
        text,
        count=1,
    )
    if n2:
        if n == 0:
            # block_hex line already removed in a prior partial patch
            pass
        return text, True

    # Alternate formatting (single-line params)
    text, n3 = re.subn(
        r'"method": "submitblock", "params": \[block_hex\]',
        '"method": "pprpcsb", "params": [state.headerHash, mixhash_hex, nonce_hex]',
        text,
        count=1,
    )
    if n3:
        text, _ = re.subn(
            r'^[ \t]*block_hex = state\.build_block\(nonce_hex, mixhash_hex\)\s*\n',
            "",
            text,
            count=1,
            flags=re.MULTILINE,
        )
        return text, True

    raise SystemExit(
        "Found submitblock but could not rewrite params. Run:\n"
        "  sed -n '220,270p' ~/ravencoin-stratum-proxy/stratum-converter.py"
    )


def patch_result_check(text: str) -> tuple[str, bool]:
    if re.search(r'if result not in \(\s*\n\s*None,\s*\n\s*True,', text):
        return text, False
    text, n = re.subn(
        r'(if result not in \(\s*\n\s*None,)',
        r'\1\n                    True,',
        text,
        count=1,
    )
    if not n:
        raise SystemExit("Could not find submit result check")
    return text, True


def patch_block_height(text: str) -> tuple[str, bool]:
    if "block_height = state.height" in text:
        return text, False
    pattern = r"""        # Get height from block hex
        block_height = int\.from_bytes\(
            bytes\.fromhex\(
                block_hex\[\(4 \+ 32 \+ 32 \+ 4 \+ 4\) \* 2 : \(4 \+ 32 \+ 32 \+ 4 \+ 4 \+ 4\) \* 2\]
            \),
            "little",
            signed=False,
        \)"""
    text, n = re.subn(pattern, "        block_height = state.height", text, count=1)
    if not n:
        # block_hex may already be gone from a partial patch
        if "block_hex[" in text and "block_height" in text:
            text, n = re.subn(
                r"        block_height = int\.from_bytes\([\s\S]*?\)\s*\n",
                "        block_height = state.height\n",
                text,
                count=1,
            )
    if not n and "block_height = state.height" not in text:
        # Non-fatal if submit path no longer references block_hex
        if "block_hex" not in text:
            text = text.replace(
                "        msg = f\"Found block (may or may not be accepted by the chain): {block_height}\"",
                "        block_height = state.height\n        msg = f\"Found block (may or may not be accepted by the chain): {block_height}\"",
            )
            return text, True
        raise SystemExit("Could not patch block_height parsing")
    return text, True


def main() -> None:
    if len(sys.argv) != 2:
        print(f"Usage: {sys.argv[0]} /path/to/stratum-converter.py", file=sys.stderr)
        sys.exit(1)

    path = Path(sys.argv[1])
    text = path.read_text()
    changes = []

    text, changed = patch_gbt(text)
    if changed:
        changes.append("getblocktemplate segwit rules")

    text, changed = patch_kawpow_updater(text)
    if changed:
        changes.append("pprpcheader job handler")

    text, changed = patch_submit(text)
    if changed:
        changes.append("pprpcsb submit")

    text, changed = patch_result_check(text)
    if changed:
        changes.append("accept true result")

    text, changed = patch_block_height(text)
    if changed:
        changes.append("block_height from state")

    if not changes:
        print("already fully patched")
        return

    path.write_text(text)
    print(f"patched {path}:")
    for c in changes:
        print(f"  - {c}")


if __name__ == "__main__":
    main()
