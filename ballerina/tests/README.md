# Tests

The suite has 30 tests across the four Key Vault areas:

- Keys: create, get, list, update, delete, backup and restore, plus the cryptographic operations encrypt, decrypt, sign and verify, and the soft-delete lifecycle (list deleted, get deleted, purge, recover).
- Secrets: set, get, list, update, delete, list versions and recover.
- Certificates: create, get, list, get policy and delete.
- Managed storage accounts: set, get and list.

Test execution order is alphabetical, so no test depends on a fixture another test created. Each test that reads, updates or deletes something creates its own uniquely named key, secret or certificate first. Key and secret versions are taken from the identifiers the vault returns, never hardcoded.

## Running Tests

```bash
bal test
```

The test suite uses a mock server (`tests/mock_service.bal`) that intercepts HTTP calls so no real credentials are required.

## Running against a live key vault

Tests in the `live_tests` group can run against a real vault. The rest are in `mock_tests` only: they need a finished asynchronous operation, such as a completed soft-delete or certificate issuance, that a test can't wait for reliably. Set the following environment variables and run the `live_tests` group:

| Variable | Description |
|----------|-------------|
| `IS_LIVE_SERVER` | Set to `true` to target a live vault instead of the mock server |
| `AZURE_KEYVAULT_URL` | The vault URI, for example `https://<vault-name>.vault.azure.net` |
| `AZURE_KEYVAULT_TOKEN` | A Microsoft Entra ID access token issued for `https://vault.azure.net` |
| `AZURE_STORAGE_RESOURCE_ID` | Resource ID of a storage account, used by the storage-account tests |

```bash
export IS_LIVE_SERVER=true
bal test --groups live_tests
```

The live tests create keys, secrets and certificates whose names start with `test-`. Use a vault set aside for testing.
