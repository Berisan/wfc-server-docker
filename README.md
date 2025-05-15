# wwfc
WiiLink Wi-Fi Connection aims to be an open source server replacement for Nintendo Wi-Fi Connection. Currently, a work in progress

## Current Support
- Matchmaking (No server sorting yet)
- Adding Friends

## Setup

TLDR:

1. Build WWFC and set up configuration file
3. Set up [Database](#database)
4. Build [Payload](#payload)
5. Set up at least one [connection method](#connection-methods)
6. Depending on the connection method, configure a custom domain or a DNS-Server
7. [Troubleshoot](#troubleshooting)

### WWFC

You need:

- [Go](https://go.dev)

Run `go build`. The resulting executable `wwfc` is the executable of the server.

Copy [config-example.xml](config-example.xml) to `config.xml` and insert all the correct data. Details below.

### Database

WWFC requires a Postgres Database to store user information like friend codes and game data.

- Install Postgres
- Create a Database
- Create a User called `wiilink`
- Import the [schema.sql](../../schema.sql) file into the Database

Then, in your `config.xml` set:

- `username` to `wiilink`
- `password` to the database user's password
- `databaseAdress` to the IP-address or domain name your Postgres server is reachable at
- `databaseName` to the name of the database you created

### Payload

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
./make.sh --all --exploit -- -j$(nproc) -DWWFC_DOMAIN=\"${DOMAIN}\"
```

The script will create a directory `dist/` which contains the payload files necessary to run the server. Copy those files into a `payload/` directory located next to your `wwfc` binary.

### Connection methods

Currently, there are three ways to connect to WWFC:

- [Wii HTTP](#connection-method---wii-http-gecko-codes): Connecting via Gecko Codes
- [Wii HTTPS](#connection-method---wii-https-wii-ssl-bug): Connecting via Custom DNS (requires [setting up HTTPS](#configuring-https))
- [DS HTTPS](#connection-method---ds-https-nds-constraint): Connecting via Custom DNS (requires [setting up HTTPS](#configuring-https))

### Connection Method - Wii HTTP (Gecko Codes)

The gecko codes will be located in the `patch/build/` directory as `.txt` files.

> [!IMPORTANT]
> The codes are made specifically for your built [payload](#patches) and will not work if you use another domain or change the payload!

### Configuring HTTPS

To enable the DS and Wii HTTPS exploits, you need to configure WWFC for normal Browser HTTPS requests first.

Create a new TLS certificate for the domain your server will be reachable under.

Then, open up your `config.xml` and set:

- `nasAddressHttps` to a reachable IP (usually the same as `nasAdress`).
- `enableHttps` to `true`
- `certPath` to your certificate
- `keyPath` to your private key

### Connection Method - DS HTTPS (nds-constraint)

The only currently supported method of connecting DS games to Wiilink WFC is through the nds-constraint exploit, requiring a custom DNS server.

> [!TIP]
> More info on how the exploit works at https://github.com/KaeruTeam/nds-constraint

You will need:
    
- The Wii's client certificate and its corresponding private key
    - These are not console-unique and can be pulled from any Wii
    - You may also use Dolphin to get the certificate files:
        - `Tools` > `Perform Online System Update`
        - `Tools` > `Manage NAND` > `Extract Certificates From NAND`
        - The necessesary files can be found in the Dolphin User Folder:
            - `%appdata%/Dolphin Emulator/Wii/clientca.pem`
            - `%appdata%/Dolphin Emulator/Wii/clientcakey.pem`
- OpenSSL
- A custom DNS server

#### Creating the Certificate

Using openssl, create a new private key and certificate for `nas.nintendowifi.net`, assuming you have the Wii's client certificate and private key saved as `clientca.pem` and `clientcakey.pem`, respectively:

```shell
openssl req -CA clientca.pem -CAkey clientcakey.pem -newkey rsa:1024 -noenc -keyout nas-key.pem -subj "/CN=nas.nintendowifi.net" -out nas-cert.der -outform DER
```

Copy the `clientca.pem`, `nas-cert.der`, `nas-key.pem` files to the same directory as your wwfc-binary.

> [!IMPORTANT]
> Make sure `clientca.pem` and `nas-cert.der` are in DER format! The WWFC-server expects them both in that format and does not do any conversion.

#### Configuring the Certificate

Time to open up your `config.xml`.

> [!IMPORTANT]
> Remember to [set up "normal" HTTPS](./configure.md#configuring-https)!

- Set `enableHttpsExploitDS` to `true`
- Set `certDerPathDS` to `nas-cert.der`
- Set `wiiCertDerPathDS` to `clientca.der`
- Set `keyPathDS` to `nas-key.pem`

#### Connecting to WWFC with your DS

You need to set up a custom DNS-server to rewrite the original WFC domains to your WWFC-server.

- Rewrite `*.nintendowifi.net` to your WWFC-server's IP


### Connection Method - Wii HTTPS (wii-ssl-bug)

You need:

- openssl
- a hex editor (or similar search & replace tool)
- a custom DNS Server

> [!TIP]
> More info on how the exploit works at https://github.com/shutterbug2000/wii-ssl-bug

> [!IMPORTANT]
> Reminder that this is **not necessary** if you use the gecko-codes and only works on **Wii IOS36 or below**

#### Creating the certificate

Create a RSA 1024 bit Certificate for naswii.nintendowifi.net in DER format:

```shell
openssl req -x509 -newkey rsa:1024 -noenc -keyout naswii-key.pem -subj "/CN=naswii.nintendowifi.net" -out naswii-cert.der -outform DER
```

Then, replace the hex byte seqence `05 00 03 81 81` with `04 00 03 81 81`:

```shell
sed -e "s/\x05\x00\x03\x81\x81/\x04\x00\x03\x81\x81/g" -i naswii-cert.der
```

#### Configuring the certificate

Time to open up your `config.xml`.

> [!IMPORTANT]
> Remember to [set up "normal" HTTPS](#configuring-https)!

- Set `enableHttpsExploitWii` to `true`
- Set `certDerPathWii` to `naswii-cert.der`
- Set `keyPathWii` to `naswii-key.pem`

#### Configuring the DNS Server

You need to set up a DNS-server to rewrite the original WFC domains to your WWFC-server.

- Rewrite `*.nintendowifi.net` to your WWFC-server's IP


### Troubleshooting

Common Errors and Troubleshooting steps (todo)

#### Ports

By default, WWFC listens the following ports, configure your firewall accordingly:

```yaml

# HTTP
- 80/tcp        # nas, sake, gamestats, race, conntest
- 443/tcp       # nas-ssl

# RPC
- 28910/tcp     # serverbrowser
- 29900/tcp     # gpcm
- 29901/tcp     # gpsp
- 29920/tcp     # gamestats
- 29998/tcp     # frontend
- 29999/tcp     # backend

# GameSpy
- 27900/udp     # qr2
- 27901/udp     # natneg
```

#### I can't connect to my server (nothing shows up in logs)

##### Wii HTTP Method (Gecko codes)

- Make sure that the patch is active
- Make sure you are using the correct patch (game region?)
- Make sure port `80` is accessible
    - You might need to allow `wwfc` through the firewall
    - Check the `gsAddress` in your `config.xml`.
        - If only allowing connections on the same device as `wwfc`, set to `127.0.0.1` or `localhost`
        - If `wwfc` should be available to external devices, set to `0.0.0.0`
- Make sure you set up your domain correctly. (`*.domain.example` => 127.0.0.1 or your server/pc's IP)

#### Error Code 20913 when trying to log in

##### Wii HTTP Method

Make sure the patches are built correctly and are located in the `patch/binary/` directory.

Your file tree should look something like this:

```
├── config.xml
├── game_list.tsv
├── motd.txt
├── patches
│   ├── RMCPD00.txt
│   └── ...
├── payload
│   ├── binary
│   │   ├── payload.RMCPD00.bin
│   │   └── ...
│   ├── private-key.pem
│   └── stage1.bin
└── wwfc
```

#### Login works but the connection just drops after a short time (Error code 91010 or 81010)

Make sure ports `27900` (QR2) and `27901` (NATNEG) are accessible via UDP.

> [!NOTE]
> WSL/VSCode Port Forwarding does not support UDP connections, you may need additional workarounds.
