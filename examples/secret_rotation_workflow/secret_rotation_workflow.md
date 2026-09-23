# Secret rotation workflow

This example rotates a secret stored in Azure Key Vault. It writes the new value as a new version of the secret, lists the secret's versions, disables every older version that is still enabled, and reads the current version back.

## Prerequisites

### 1. Set up

Refer to the [setup guide](https://github.com/ballerina-platform/module-ballerinax-azure.keyvault/tree/main/README.md#setup-guide) to create a key vault and obtain an access token.

### 2. Configuration

Create a `Config.toml` file in the example's root directory with the following values:

```toml
keyVaultUrl = "https://<vault-name>.vault.azure.net"
token = "<access-token>"
secretName = "<secret-name>"
newSecretValue = "<new-secret-value>"
```

## Run the example

Execute the following command to run the example. The script will print its progress to the console.

```bash
bal run
```
