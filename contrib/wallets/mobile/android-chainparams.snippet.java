// Reference values for Raven Android fork — locate MainNetParams / ChainParams and align fields.
// Source of truth: contrib/wallets/hnb-network.json

public static final int MAINNET_PORT = 28888;
public static final int MAINNET_RPC_PORT = 28887;

public static final byte[] MAINNET_PACKET_MAGIC = { (byte)0xa1, (byte)0xb2, (byte)0xc3, (byte)0xd4 };

public static final int PUBKEY_ADDRESS_PREFIX = 40;   // H...
public static final int SCRIPT_ADDRESS_PREFIX = 85;
public static final int SECRET_KEY_PREFIX = 200;

public static final int BIP44_COIN_TYPE = 1919;
public static final String DEFAULT_HD_PATH = "m/44'/1919'/0'/0/0";

public static final String GENESIS_HASH =
    "0000005bc2484f740d4c3087211e3aa44d33e7691c9dfdf099b823f735f0be2b";

// Testnet
public static final int TESTNET_PORT = 28890;
public static final byte[] TESTNET_PACKET_MAGIC = { 0x48, 0x4e, 0x42, 0x54 }; // HNBT
public static final int TESTNET_PUBKEY_PREFIX = 111;  // m...
