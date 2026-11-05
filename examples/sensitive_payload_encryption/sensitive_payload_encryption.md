# Sensitive payload encryption

This example creates an RSA key in Azure Key Vault that may only encrypt and decrypt, encrypts a sensitive payload with it using RSA-OAEP-256, and decrypts the ciphertext again to confirm the round trip. The private key never leaves the vault.

## Prerequisites

### 1. Set up

Refer to the [setup guide](https://github.com/ballerina-platform/module-ballerinax-azure.keyvault/tree/main/README.md#setup-guide) to create a key vault and obtain an access token.

### 2. Configuration

Create a `Config.toml` file in the example's root directory with the following values:

```toml
keyVaultUrl = "https://<vault-name>.vault.azure.net"
token = "<access-token>"
keyName = "<key-name>"
```

## Run the example

Execute the following command to run the example. The script will print its progress to the console.

```bash
bal run
```
