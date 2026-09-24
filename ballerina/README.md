## Overview

[Azure Key Vault](https://azure.microsoft.com/en-us/products/key-vault/) is a Microsoft Azure cloud service for safely storing and accessing secrets, cryptographic keys, certificates and managed storage-account keys, with access governed by Microsoft Entra ID.

The Azure Key Vault connector exposes the Key Vault data-plane REST API to Ballerina programs. It has the same operation surface as API version 7.0, and covers all 78 of its operations: key management and cryptography, secrets, certificates and certificate issuers, and managed storage accounts with their SAS definitions, including soft-delete, recovery, backup and restore.

### Key features

- Create, import, rotate and back up cryptographic keys, and use them to encrypt, decrypt, sign, verify, wrap and unwrap data without the private key leaving the vault
- Store, version, update and rotate secrets such as passwords, connection strings and API keys
- Issue and import certificates, manage their policies, issuers and contacts, and follow pending certificate operations
- Manage Key Vault-managed storage accounts, key regeneration and SAS definitions
- Recover or purge soft-deleted keys, secrets, certificates and storage accounts

## Setup guide

To use the Azure Key Vault connector, you need a key vault, permission to use it, and a Microsoft Entra ID access token issued for Key Vault.

1. Sign in to the [Azure portal](https://portal.azure.com/) with an account that has an active subscription.

2. Create a key vault: search for **Key vaults**, select **Create**, choose a subscription, resource group, region and a globally unique vault name, and create it. Note the **Vault URI** on the vault's **Overview** page, for example `https://<vault-name>.vault.azure.net`. The connector sends every request to this URI.

3. Grant the identity that will call the vault access to its data plane. On a vault that uses Azure role-based access control, open **Access control (IAM)** and assign the roles the program needs, such as **Key Vault Secrets Officer**, **Key Vault Crypto Officer** or **Key Vault Certificates Officer**. On a vault that uses access policies, add an access policy with the matching key, secret and certificate permissions instead.

4. Obtain an access token for the `https://vault.azure.net` resource. For local development, sign in with the [Azure CLI](https://learn.microsoft.com/en-us/cli/azure/install-azure-cli) and run:

    ```bash
    az account get-access-token --resource https://vault.azure.net --query accessToken --output tsv
    ```

    For an unattended service, use an application registered in Microsoft Entra ID:

    1. In the Azure portal, open the app launcher and select **Entra**.

        ![Open Microsoft Entra from the Azure portal](https://raw.githubusercontent.com/ballerina-platform/module-ballerinax-azure.keyvault/main/docs/resources/azure-portal.png)

    2. Select **App registrations**, then **New registration**. Give the application a name, choose **Accounts in this organizational directory only**, and register it. Note the **Application (client) ID** and **Directory (tenant) ID** on its **Overview** page.

        ![Open App registrations in Microsoft Entra](https://raw.githubusercontent.com/ballerina-platform/module-ballerinax-azure.keyvault/main/docs/resources/entra-main-page.png)

    3. Open **Certificates & secrets**, select **New client secret**, and copy the secret's **Value** as soon as it is created. It is shown only once.

        ![Create a client secret](https://raw.githubusercontent.com/ballerina-platform/module-ballerinax-azure.keyvault/main/docs/resources/add-client-secret.png)

    4. Grant the application's service principal access to the vault as in step 3, then request a token with the OAuth 2.0 client credentials flow from `https://login.microsoftonline.com/<tenant-id>/oauth2/v2.0/token`, using the scope `https://vault.azure.net/.default`.

> **Note:** The connector authenticates with a bearer token and does not refresh it. Access tokens expire, typically after about an hour, so a long-running program must obtain a fresh token and create a new client when the token expires.

## Quickstart

To use the Azure Key Vault connector in your Ballerina application, update the `.bal` file as follows:

### Step 1: Import the module

Import the `azure.keyvault` module.

```ballerina
import ballerinax/azure.keyvault;
```

### Step 2: Instantiate a new connector

Create a `keyvault:Client` with the vault URI and an access token.

```ballerina
configurable string keyVaultUrl = ?;
configurable string token = ?;

final keyvault:Client keyVault = check new ({auth: {token}}, keyVaultUrl);
```

Provide the values in a `Config.toml` file:

```toml
keyVaultUrl = "https://<vault-name>.vault.azure.net"
token = "<access-token>"
```

### Step 3: Invoke the connector operation

Store a secret in the vault. Every operation takes the Key Vault REST API version as `apiVersion`.

```ballerina
public function main() returns error? {
    keyvault:SecretBundle _ = check keyVault->setSecret("db-password", {value: "s3cr3t-value"}, apiVersion = "7.0");
}
```

### Step 4: Run the Ballerina application

```bash
bal run
```

## Examples

The Azure Key Vault connector provides practical examples illustrating usage in various scenarios. Explore these [examples](https://github.com/ballerina-platform/module-ballerinax-azure.keyvault/tree/main/examples/), covering the following use cases:

1. [Secret rotation workflow](https://github.com/ballerina-platform/module-ballerinax-azure.keyvault/tree/main/examples/secret_rotation_workflow) - Store a new secret version and disable the older ones.
2. [Sensitive payload encryption](https://github.com/ballerina-platform/module-ballerinax-azure.keyvault/tree/main/examples/sensitive_payload_encryption) - Create an RSA key and encrypt and decrypt a payload with it.
3. [Document signing and verification](https://github.com/ballerina-platform/module-ballerinax-azure.keyvault/tree/main/examples/document_signing_verification) - Sign a document digest with a vault key and verify the signature.
4. [Self-signed certificate provisioning](https://github.com/ballerina-platform/module-ballerinax-azure.keyvault/tree/main/examples/self_signed_certificate_provisioning) - Issue a self-signed certificate and inspect its policy and versions.
