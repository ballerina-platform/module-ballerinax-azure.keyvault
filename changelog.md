# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

### Added

- The connector can authenticate with an OAuth 2.0 refresh token or client credentials through Microsoft Entra ID,
  as well as a bearer token. With the OAuth 2.0 grants it renews access tokens itself; a bearer token is used
  as given and must be replaced when it expires. `ConnectionConfig.auth` accepts
  `OAuth2RefreshTokenGrantConfig` and `OAuth2ClientCredentialsGrantConfig`.
- A `*Queries` record for each operation, such as `SetSecretQueries` and `ListSecretsQueries`,
  which carries the operation's query parameters, including the required `apiVersion`.
- An optional `headers` argument on every remote method, for sending extra request headers.
- The `StorageAccountRegenerateKeyParameters` record, the payload of `regenerateStorageAccountKey`.

### Changed

- **Breaking:** the methods that list a collection are renamed from `get*` to `list*`:

    | 1.6.1 | 2.0.0 |
    |---|---|
    | `getKeys` | `listKeys` |
    | `getKeyVersions` | `listKeyVersions` |
    | `getDeletedKeys` | `listDeletedKeys` |
    | `getSecrets` | `listSecrets` |
    | `getSecretVersions` | `listSecretVersions` |
    | `getDeletedSecrets` | `listDeletedSecrets` |
    | `getCertificates` | `listCertificates` |
    | `getCertificateVersions` | `listCertificateVersions` |
    | `getCertificateIssuers` | `listCertificateIssuers` |
    | `getDeletedCertificates` | `listDeletedCertificates` |
    | `getStorageAccounts` | `listStorageAccounts` |
    | `getDeletedStorageAccounts` | `listDeletedStorageAccounts` |
    | `getSasDefinitions` | `listSasDefinitions` |
    | `getDeletedSasDefinitions` | `listDeletedSasDefinitions` |

- **Breaking:** query parameters are no longer positional. `apiVersion`, `maxresults` and the
  other query parameters are passed as named arguments (or as the operation's `*Queries` record)
  after the path parameters and payload:

    ```ballerina
    // 1.6.1
    keyvault:SecretBundle secret = check vault->setSecret("db-password", "7.0", {value: "s3cret"});
    keyvault:SecretListResult secrets = check vault->getSecrets("7.0", 10);
    ```

    ```ballerina
    // 2.0.0
    keyvault:SecretBundle secret = check vault->setSecret("db-password", {value: "s3cret"}, apiVersion = "7.0");
    keyvault:SecretListResult secrets = check vault->listSecrets(apiVersion = "7.0", maxresults = 10);
    ```

- **Breaking:** `purgeDeletedKey`, `purgeDeletedSecret`, `purgeDeletedCertificate` and
  `purgeDeletedStorageAccount` return `error?` (was `http:Response|error`).
- **Breaking:** `maxresults` is an `int:Signed32` constrained to 1–25 (was `int?`), matching the
  limit the service enforces.
- **Breaking:** `ConnectionConfig.http1Settings` is an `http:ClientHttp1Settings` and
  `ConnectionConfig.proxy` an `http:ProxyConfig`, in place of the connector's own records.
- `DeletedKeyBundle`, `DeletedKeyItem`, `DeletedSecretBundle`, `DeletedSecretItem`,
  `DeletedCertificateBundle`, `DeletedCertificateItem`, `DeletedStorageBundle`,
  `DeletedStorageAccountItem`, `DeletedSasDefinitionBundle` and `DeletedSasDefinitionItem` are
  records that include their base type, rather than aliases of it.
- The connector declares Ballerina 2201.12.0 (Swan Lake Update 12) as its distribution.

### Removed

- **Breaking:** the misspelt `StorageAccountRegenerteKeyParameters` record. Use
  `StorageAccountRegenerateKeyParameters`.
- **Breaking:** the connector's own `ClientHttp1Settings` and `ProxyConfig` records.
- **Breaking:** the `KeyVaultError` and `PendingCertificateSigningRequestResult` records. No
  method returned either. A failed call returns an `http:ClientRequestError` or
  `http:RemoteServerError` whose detail carries the error body.

### Fixed

- Deleted keys, secrets, certificates, storage accounts and SAS definitions now carry
  `recoveryId`, `scheduledPurgeDate` and `deletedDate`, which 1.6.1 dropped from the response.
- `KeyAttributes`, `SecretAttributes` and `CertificateAttributes` now carry `recoveryLevel`,
  which 1.6.1 dropped from the response.
