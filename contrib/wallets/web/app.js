import { generateMnemonic, mnemonicToSeedSync, validateMnemonic } from 'https://esm.sh/bip39@3.1.0';
import { BIP32Factory } from 'https://esm.sh/bip32@4.0.0';
import * as ecc from 'https://esm.sh/tiny-secp256k1@2.2.3';
import { payments } from 'https://esm.sh/bitcoinjs-lib@6.1.5';

const bip32 = BIP32Factory(ecc);

const NET = {
  mainnet: {
    path: "m/44'/1919'/0'/0/0",
    bitcoinjs: {
      messagePrefix: '\x18HookersAndBlow Signed Message:\n',
      bech32: 'hnb',
      bip32: { public: 0x0488b21e, private: 0x0488ade4 },
      pubKeyHash: 40,
      scriptHash: 85,
      wif: 200,
    },
    rpcDefault: 'http://127.0.0.1:28887/',
  },
  testnet: {
    path: "m/44'/1'/0'/0/0",
    bitcoinjs: {
      messagePrefix: '\x18HookersAndBlow Signed Message:\n',
      bech32: 'tnb',
      bip32: { public: 0x043587cf, private: 0x04358394 },
      pubKeyHash: 111,
      scriptHash: 196,
      wif: 239,
    },
    rpcDefault: 'http://127.0.0.1:28889/',
  },
};

const $ = (id) => document.getElementById(id);

function setStatus(msg, ok = false) {
  const el = $('status');
  el.textContent = msg;
  el.className = ok ? 'ok' : '';
}

function currentNet() {
  return NET[$('network').value];
}

function deriveFromMnemonic(mnemonic) {
  const net = currentNet();
  const words = mnemonic.trim().toLowerCase().replace(/\s+/g, ' ');
  if (!validateMnemonic(words)) {
    throw new Error('Invalid mnemonic');
  }
  const seed = mnemonicToSeedSync(words);
  const root = bip32.fromSeed(seed, net.bitcoinjs);
  const child = root.derivePath(net.path);
  const { address } = payments.p2pkh({ pubkey: child.publicKey, network: net.bitcoinjs });
  return { address, wif: child.toWIF(), path: net.path };
}

function showWallet(info) {
  $('wallet-panel').hidden = false;
  $('hd-path').textContent = info.path;
  $('address').textContent = info.address;
  $('wif').textContent = info.wif;
}

$('btn-generate').addEventListener('click', () => {
  const m = generateMnemonic(128);
  $('mnemonic').value = m;
  setStatus('New mnemonic generated — back it up offline.', true);
});

$('btn-import').addEventListener('click', () => {
  try {
    const info = deriveFromMnemonic($('mnemonic').value);
    showWallet(info);
    setStatus('Wallet derived.', true);
  } catch (e) {
    setStatus(e.message || String(e));
  }
});

$('network').addEventListener('change', () => {
  const net = currentNet();
  $('rpc-url').placeholder = net.rpcDefault;
  if ($('mnemonic').value.trim()) {
    $('btn-import').click();
  }
});

$('btn-balance').addEventListener('click', async () => {
  const addr = $('address').textContent;
  if (!addr) {
    setStatus('Derive a wallet first.');
    return;
  }
  const url = ($('rpc-url').value || currentNet().rpcDefault).replace(/\/$/, '');
  $('balance').textContent = '…';
  try {
    const res = await fetch(url, {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({ jsonrpc: '1.0', id: 'hnb', method: 'getreceivedbyaddress', params: [addr, 0] }),
    });
    const json = await res.json();
    if (json.error) throw new Error(json.error.message);
    $('balance').textContent = `${json.result} HNB (received, unconfirmed ok)`;
  } catch (e) {
    $('balance').textContent = `RPC failed: ${e.message}. Run ravend with CORS or use desktop wallet.`;
  }
});

$('rpc-url').placeholder = currentNet().rpcDefault;
