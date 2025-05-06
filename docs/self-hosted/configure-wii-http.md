# Setting up: Wii HTTP (self-hosted)

> [!NOTE]
> This page is intended for server owners looking to self-host a WWFC instance. If you're just looking to play online, check out the [user setup guide](https://wfc.wiilink24.com/setup).

## Gecko codes

You need:

- Python 3.11+ with the `cryptography` module
- [devkitPPC](https://devkitpro.org/wiki/Getting_Started)
- A domain name under which your WWFC server will be reachable (in this guide referred to as `${DOMAIN}`)

First, clone the wfc-patcher-wii repository:

```sh
git clone https://github.com/WiiLink24/wfc-patcher-wii.git
```

To build everything, run the `make.sh` script:

```sh
./make.sh --all -- -j8 -DWWFC_DOMAIN=\"${DOMAIN}\"
```

The script will create a directory `dist/` which contains the payload files necessary to run the server. Copy those files into a `payload/` directory located next to your `wwfc` binary.

The gecko codes will be located in the `patch/build/` directory as `.txt` files.