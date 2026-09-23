# Self-signed certificate provisioning

This example requests a self-signed TLS certificate from Azure Key Vault, polls the pending certificate operation until issuance completes, and then reads back the certificate policy and the issued versions.

## Prerequisites

### 1. Set up

Refer to the [setup guide](https://github.com/ballerina-platform/module-ballerinax-azure.keyvault/tree/main/README.md#setup-guide) to create a key vault and obtain an access token.

### 2. Configuration

Create a `Config.toml` file in the example's root directory with the following values:

```toml
keyVaultUrl = "https://<vault-name>.vault.azure.net"
token = "<access-token>"
certificateName = "<certificate-name>"
subject = "CN=www.contoso.com"
```

## Run the example

Execute the following command to run the example. The script will print its progress to the console.

```bash
bal run
```
