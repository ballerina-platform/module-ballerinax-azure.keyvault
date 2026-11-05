# Ballerina Azure Key Vault connector

[![Build](https://github.com/ballerina-platform/module-ballerinax-azure.keyvault/actions/workflows/ci.yml/badge.svg)](https://github.com/ballerina-platform/module-ballerinax-azure.keyvault/actions/workflows/ci.yml)
[![GitHub Last Commit](https://img.shields.io/github/last-commit/ballerina-platform/module-ballerinax-azure.keyvault.svg)](https://github.com/ballerina-platform/module-ballerinax-azure.keyvault/commits/master)
[![GitHub Issues](https://img.shields.io/github/issues/ballerina-platform/ballerina-library/module/azure.keyvault.svg?label=Open%20Issues)](https://github.com/ballerina-platform/ballerina-library/labels/module%azure.keyvault)

## Overview

[Azure Key Vault](https://azure.microsoft.com/en-us/products/key-vault/) is a Microsoft Azure cloud service for safely storing and accessing secrets, cryptographic keys, certificates and managed storage-account keys, with access governed by Microsoft Entra ID.

The Azure Key Vault connector exposes the Key Vault data-plane REST API to Ballerina programs. It has the same operation surface as API version 7.0, and covers all 78 of its operations: key management and cryptography, secrets, certificates and certificate issuers, and managed storage accounts with their SAS definitions, including soft-delete, recovery, backup and restore.

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

## Build from the source

### Setting up the prerequisites

1. Download and install Java SE Development Kit (JDK) version 21. You can download it from either of the following sources:

    * [Oracle JDK](https://www.oracle.com/java/technologies/downloads/)
    * [OpenJDK](https://adoptium.net/)

   > **Note:** After installation, remember to set the `JAVA_HOME` environment variable to the directory where JDK was installed.

2. Download and install [Ballerina Swan Lake](https://ballerina.io/).

3. Download and install [Docker](https://www.docker.com/get-started).

   > **Note**: Ensure that the Docker daemon is running before executing any tests.

4. Export Github Personal access token with read package permissions as follows,

    ```bash
    export packageUser=<Username>
    export packagePAT=<Personal access token>
    ```

### Build options

Execute the commands below to build from the source.

1. To build the package:

   ```bash
   ./gradlew clean build
   ```

2. To run the tests:

   ```bash
   ./gradlew clean test
   ```

3. To build the without the tests:

   ```bash
   ./gradlew clean build -x test
   ```

4. To run tests against different environments:

   ```bash
   ./gradlew clean test -Pgroups=<Comma separated groups/test cases>
   ```

5. To debug the package with a remote debugger:

   ```bash
   ./gradlew clean build -Pdebug=<port>
   ```

6. To debug with the Ballerina language:

   ```bash
   ./gradlew clean build -PbalJavaDebug=<port>
   ```

7. Publish the generated artifacts to the local Ballerina Central repository:

    ```bash
    ./gradlew clean build -PpublishToLocalCentral=true
    ```

8. Publish the generated artifacts to the Ballerina Central repository:

   ```bash
   ./gradlew clean build -PpublishToCentral=true
   ```

## Contribute to Ballerina

As an open-source project, Ballerina welcomes contributions from the community.

For more information, go to the [contribution guidelines](https://github.com/ballerina-platform/ballerina-lang/blob/master/CONTRIBUTING.md).

## Code of conduct

All the contributors are encouraged to read the [Ballerina Code of Conduct](https://ballerina.io/code-of-conduct).

## Useful links

* For more information go to the [`azure.keyvault` package](https://central.ballerina.io/ballerinax/azure.keyvault/latest).
* For example demonstrations of the usage, go to [Ballerina By Examples](https://ballerina.io/learn/by-example/).
* Chat live with us via our [Discord server](https://discord.gg/ballerinalang).
* Post all technical questions on Stack Overflow with the [#ballerina](https://stackoverflow.com/questions/tagged/ballerina) tag.
