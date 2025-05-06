# Setting up: DS HTTPS (self-hosted)

> [!NOTE]
> This page is intended for server owners looking to self-host a WWFC instance. If you're just looking to play online, set [the DNS server](https://wfc.wiilink24.com) in your Wifi settings.

The only currently supported method of connecting DS games to Wiilink WFC is through the nds-constraint exploit, requiring a custom DNS server.

## Certificate (nds-constraint)

> [!TIP]
> More info on how the exploit works at https://github.com/KaeruTeam/nds-constraint

You will need:
    
- The Wii's client certificate and its corresponding private key
    - These are not console-unique and can be pulled from any Wii. 
    - If you imported a NAND into Dolphin, you can just copy the certificate files from the Dolphin Data Folder:
        - `%appdata%/Dolphin Emulator/Wii/clientca.pem`
        - `%appdata%/Dolphin Emulator/Wii/clientcakey.pem`
- OpenSSL
- A custom DNS server

### Creating the Certificate

Using openssl, create a new private key and certificate for `nas.nintendowifi.net`, assuming you have the Wii's client certificate and key saved as `clientca.pem` and `clientcakey.pem`, respectively:

```shell
openssl req -CA clientca.pem -CAkey clientcakey.pem -newkey rsa:1024 -noenc -keyout nas-key.pem -subj "/CN=nas.nintendowifi.net" -out nas-cert.der -outform DER
```

Copy the clientca.pem, nas-cert.der, nas-key.pem to the same directory as your wwfc-binary.

> [!IMPORTANT]
> Make sure `clientca.pem` and `nas-cert.der` are in DER format! The WWFC-server expects them both in that format and does not do any conversion.

### Configuring the Certificate

Time to open up your `config.xml`.

> [!IMPORTANT]
> Remember to [set up "normal" HTTPS](./configure.md#configuring-https)!

- Set `enableHttpsExploitDS` to `true`
- Set `certDerPathDS` to `nas-cert.der`
- Set `wiiCertDerPathDS` to `clientca.der`
- Set `keyPathDS` to `nas-key.pem`

### Connecting to WWFC with your DS

You need to set up a custom DNS-server to rewrite the original WFC domains to your WWFC-server.

- Rewrite `*.nintendowifi.net` to your WWFC-server's IP
