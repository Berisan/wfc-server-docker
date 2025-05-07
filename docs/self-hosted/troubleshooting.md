# Troubleshooting

Common Errors and Troubleshooting steps (todo)

## I can't connect to my server (nothing shows up in logs)

### Wii HTTP Method (Gecko codes)

- Make sure that the patch is active
- Make sure you are using the correct patch (game region?)
- Make sure port `80` is accessible
    - You might need to allow `wwfc` through the firewall
    - Check the `gsAddress` in your `config.xml`.
        - If only allowing connections on the same device as `wwfc`, set to `127.0.0.1` or `localhost`
        - If `wwfc` should be available to external devices, set to `0.0.0.0`
- Make sure you set up your domain correctly. (`*.domain.example` => 127.0.0.1 or your server/pc's IP)

## Error Code 20913 when trying to log in

### Wii HTTP Method

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

## Login works but the connection just drops after some time (Error code 91010 or 81010)

Make sure ports `27900` (QR2) and `27901` (NATNEG) are accessible via UDP.

Note that WSL/VSCode Port Forwarding does not support UDP connections.