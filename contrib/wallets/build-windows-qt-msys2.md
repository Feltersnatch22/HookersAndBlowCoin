# Windows Qt wallet (raven-qt.exe)

Native GUI for Windows — **black / grey / pink** HNB branding included.

## Option A — Download from CI (easiest)

1. Open [Actions → Build Windows Qt Wallet](https://github.com/Feltersnatch22/HookersAndBlowCoin/actions/workflows/build-windows-qt.yml)
2. Download the **windows-qt** artifact (`raven-*-win64-qt.zip`)
3. Unzip anywhere (e.g. `C:\HNB\`)
4. Run **`raven-qt.exe`**

First launch creates `%APPDATA%\Raven\` config. For mainnet, add `mainnet.conf` or use defaults (P2P **28888**, RPC **28887**).

## Option B — Build locally with MSYS2

1. Install [MSYS2](https://www.msys2.org/) → open **MSYS2 MINGW64** (not MSYS)
2. Install deps:

```bash
pacman -S --needed base-devel git autoconf automake libtool bison \
  mingw-w64-x86_64-toolchain mingw-w64-x86_64-qt5 mingw-w64-x86_64-boost \
  mingw-w64-x86_64-openssl mingw-w64-x86_64-libevent mingw-w64-x86_64-miniupnpc \
  mingw-w64-x86_64-zeromq mingw-w64-x86_64-qrencode mingw-w64-x86_64-protobuf \
  mingw-w64-x86_64-db
```

3. Clone repo and build:

```bash
cd /c/path/to/HookersAndBlowCoin
bash ./.github/scripts/build-windows-qt-msys2.sh
```

Output: `release/raven-*-win64-qt.zip`

## Notes

- Zip includes `raven-qt.exe`, `ravend.exe`, `raven-cli.exe`, and Qt DLLs (via `windeployqt`).
- Wallet uses Berkeley DB from MSYS2 (`--with-incompatible-bdb`); backups are not portable to the Linux BDB 4.8 build without migration.
- Linux GUI: [build-desktop-qt.sh](build-desktop-qt.sh)
