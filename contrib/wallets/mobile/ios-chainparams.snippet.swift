// Reference for Raven iOS fork — align with BRChainParams / network config.
// Source of truth: contrib/wallets/hnb-network.json

enum HNBMainNet {
    static let port = 28888
    static let rpcPort = 28887
    static let packetMagic: [UInt8] = [0xa1, 0xb2, 0xc3, 0xd4]
    static let pubkeyAddressPrefix: UInt8 = 40
    static let scriptAddressPrefix: UInt8 = 85
    static let secretKeyPrefix: UInt8 = 200
    static let bip44CoinType: UInt32 = 1919
    static let defaultHdPath = "m/44'/1919'/0'/0/0"
    static let genesisHash =
        "0000005bc2484f740d4c3087211e3aa44d33e7691c9dfdf099b823f735f0be2b"
}

enum HNBTestNet {
    static let port = 28890
    static let packetMagic: [UInt8] = [0x48, 0x4e, 0x42, 0x54]
    static let pubkeyAddressPrefix: UInt8 = 111
    static let bip44CoinType: UInt32 = 1
}
