# Setting up: Wii HTTPS (self-hosted)

> [!NOTE]
> This page is intended for server owners looking to self-host a WWFC instance. If you're just looking to play online, check out the [user setup guide](https://wfc.wiilink24.com/setup).

This guide explains how to set up WWFC to accept HTTPS connections from a Wii. You will need:

- openssl
- a custom DNS Server


> [!TIP]
> More info on how the exploit works at https://github.com/shutterbug2000/wii-ssl-bug

> [!NOTE]
> Reminder that this is **not necessary** if you use the gecko-codes and only works on **physical consoles** for now.

## Creating the certificate

Create a RSA 1024 bit Certificate for naswii.nintendowifi.net in DER format:

```shell
openssl req -x509 -newkey rsa:1024 -noenc -keyout naswii-key.pem -subj "/CN=naswii.nintendowifi.net" -out naswii-cert.der -outform DER
```

Open `naswii-cert.der` in a Hex Editor.

Find `05 00 03 81 81` and replace with `04 00 03 81 81`

Convert the certificate back to PEM.

## Configuring the certificate

Time to open up your `config.xml`.

> [!IMPORTANT]
> Remember to [set up "normal" HTTPS](./configure.md#configuring-https)!

- Set `enableHttpsExploitWii` to `true`
- Set `certDerPathWii` to `naswii-cert.der`
- Set `keyPathWii` to `naswii-key.pem`

## Configuring the DNS Server

You need to set up a DNS-server to rewrite the original WFC domains to your WWFC-server.

- Rewrite `*.nintendowifi.net` to your WWFC-server's IP

