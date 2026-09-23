# Document signing and verification

This example finds the newest enabled version of an existing RSA key in Azure Key Vault, signs the SHA-256 digest of a document with it using RS256, and verifies the resulting signature. The key must permit the `sign` and `verify` operations.

## Prerequisites

### 1. Set up

Refer to the [setup guide](https://github.com/ballerina-platform/module-ballerinax-azure.keyvault/tree/main/README.md#setup-guide) to create a key vault and obtain an access token.

### 2. Configuration

Create a `Config.toml` file in the example's root directory with the following values:

```toml
keyVaultUrl = "https://<vault-name>.vault.azure.net"
token = "<access-token>"
signingKeyName = "<signing-key-name>"
document = "<text-to-sign>"
```

## Run the example

Execute the following command to run the example. The script will print its progress to the console.

```bash
bal run
```
