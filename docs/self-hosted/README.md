# Setting up WWFC

> [!NOTE]
> This page is intended for server owners looking to self-host a WWFC instance. If you're just looking to play online, check out the [user setup guide](https://wfc.wiilink24.com/setup).

WIP

## Connection methods

You need to set up at least one connection method in order to play on your WWFC instance.

- [Wii HTTP](./configure-wii-http.md)
- [Wii HTTPS](./configure-wii-https.md) (requires [setting up HTTPS](#configuring-https))
- [DS HTTPS](./configure-ds-https.md) (requires [setting up HTTPS](#configuring-https))

## Database

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

## Configuring HTTPS

To enable the DS and Wii HTTPS exploits, you need to configure WWFC for normal Browser HTTPS requests first.

Create a new TLS certificate for the domain your server will be reachable under.

Then, open up your `config.xml` and set:

- `nasAddressHttps` to a reachable IP (usually the same as `nasAdress`).
- `enableHttps` to `true`
- `certPath` to your certificate
- `keyPath` to your private key
