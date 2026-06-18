// Copyright (c) 2009-2016 The Bitcoin Core developers
// Copyright (c) 2017-2021 The HookersAndBlow Core developers
// Distributed under the MIT software license, see the accompanying
// file COPYING or http://www.opensource.org/licenses/mit-license.php.

#if defined(HAVE_CONFIG_H)
#include "config/raven-config.h"
#endif

#include "chainparams.h"
#include "arith_uint256.h"
#include "primitives/block.h"
#include "util.h"
#include <iostream>
#include <cstdint>

int main(int argc, char* argv[])
{
    SelectParams(CBaseChainParams::MAIN);

    const CBlock& genesis = Params().GenesisBlock();

    arith_uint256 target;
    bool fNegative, fOverflow;
    target.SetCompact(genesis.nBits, &fNegative, &fOverflow);

    if (fNegative || fOverflow || target == 0) {
        std::cerr << "Invalid nBits" << std::endl;
        return 1;
    }

    uint256 hash = genesis.GetX16RHash();

    std::cout << "Genesis verification" << std::endl;
    std::cout << "Hash: " << hash.GetHex() << std::endl;
    std::cout << "nTime: " << genesis.nTime << std::endl;
    std::cout << "nNonce: " << genesis.nNonce << std::endl;
    std::cout << "Merkle Root: " << genesis.hashMerkleRoot.GetHex() << std::endl;
    std::cout << "Target: " << target.GetHex() << std::endl;

    if (UintToArith256(hash) > target) {
        std::cerr << "ERROR: genesis hash does not meet proof-of-work target" << std::endl;
        return 1;
    }

    std::cout << "Genesis block is valid." << std::endl;
    return 0;
}
