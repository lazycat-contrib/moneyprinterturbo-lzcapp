# MoneyPrinterTurbo for LazyCat

LazyCat LPK v2 packaging for [MoneyPrinterTurbo](https://github.com/harry0703/MoneyPrinterTurbo), which generates HD short videos from a topic or keyword using AI models and an automated workflow.

## Runtime

- Single-instance WebUI on the LazyCat application domain.
- Internal API service on port 8080; it is not exposed as a public route.
- Both services use the same `ghcr.io/harry0703/moneyprinterturbo:1.3.6` linux/amd64 image through the `ghcr.1ms.run` mirror, pinned by digest.
- The original Compose file's unsupported `config.toml` file bind is replaced by startup wrappers that initialize a persistent configuration under `/lzcapp/var` and link it into the application directory.
- Generated media persists under `/lzcapp/var/moneyprinterturbo/storage`.
- File uploads and downloads use the LazyCat file-picker injection.

The supplied logo was converted to PNG without resizing and remains 96×96.

## Build

```sh
lzc-cli project release -o dist/application.lpk
```

## GitHub Actions

The scheduled workflow follows stable SemVer image tags, updates both the WebUI and API service explicitly, creates a versioned GitHub Release asset, and publishes only to the MiaoMiao private store.

Required repository or organization Secrets:

- `APPSTORE_URL`
- `APPSTORE_TOKEN`

Optional Secrets:

- `APP_ID`
- `PRIVATE_STORE_GROUP_CODES`
