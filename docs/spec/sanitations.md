_Author_: @DimuthuMadushan \
_Created_: 2026/09/23 \
_Updated_: 2026/09/23 \
_Edition_: Swan Lake

# Sanitation for OpenAPI specification

This document records the sanitation done on top of the official OpenAPI specification from Azure Key Vault. 
The OpenAPI specification is obtained from the [Azure Key Vault 7.0-preview specification](https://github.com/wso2/api-specs/blob/main/openapi/azure/keyvault/7.0-preview/openapi.json) (`openapi/azure/keyvault/7.0-preview/openapi.json` in `api-specs`), which is the upstream `KeyVaultClient` Swagger 2.0 document.
These changes are done in order to improve the overall usability, and as workarounds for some known language limitations.

1. **Added the `azure_auth` security scheme** (applied to `docs/spec/openapi.json`, before flatten and align)

   **Location**: top level — `securityDefinitions` and `security`

   **Original**: The specification declared no security scheme. The upstream document relies on AutoRest's host-side authentication, so the generated `ConnectionConfig` had no `auth` field.

   **Updated**: Added an `azure_auth` OAuth 2.0 scheme (implicit flow, authorization URL `https://login.microsoftonline.com/common/oauth2/authorize`, scope `user_impersonation`) and a top-level `security: [{"azure_auth": ["user_impersonation"]}]`. This is the same scheme the previously published connector (`ballerinax/azure.keyvault` 1.6.1) declared.

   **Reason**: Every Key Vault data-plane call needs a Microsoft Entra ID bearer token. With the scheme in place, the generated `ConnectionConfig` carries `http:BearerTokenConfig auth`.

2. **Moved `properties` declared beside `allOf` into the `allOf`** (applied to `docs/spec/aligned_ballerina_openapi.json`)

   **Location**: `components.schemas` — `DeletedKeyBundle`, `DeletedKeyItem`, `DeletedSecretBundle`, `DeletedSecretItem`, `DeletedCertificateBundle`, `DeletedCertificateItem`, `DeletedStorageBundle`, `DeletedStorageAccountItem`, `DeletedSasDefinitionBundle`, `DeletedSasDefinitionItem`, `KeyAttributes`, `SecretAttributes`, `CertificateAttributes`

   **Original**: `{"allOf": [{"$ref": "<Base>"}], "properties": {...}}`. This is AutoRest's inheritance pattern.

   **Updated**: `{"allOf": [{"$ref": "<Base>"}, {"type": "object", "properties": {...}}]}`.

   **Reason**: The Ballerina OpenAPI tool ignores `properties` placed beside `allOf`. Each of these types was generated as a bare alias of its base type (for example `DeletedKeyBundle` as `KeyBundle`, `KeyAttributes` as `Attributes`), silently dropping `recoveryId`, `scheduledPurgeDate`, `deletedDate` and `recoveryLevel`.

3. **Kept the descriptions of `$ref` properties** (applied to `docs/spec/aligned_ballerina_openapi.json`)

   **Location**: 44 properties across `components.schemas` that are a bare `$ref`, for example `KeyBundle.attributes`, `KeyBundle.key`, `CertificateBundle.policy`, `IssuerBundle.credentials` and `LifetimeAction.trigger`

   **Original**: `{"$ref": "..."}`. The description written beside the `$ref` in the source document is dropped by flatten and align, because OpenAPI 3.0 ignores keys that sit beside `$ref`.

   **Updated**: `{"allOf": [{"$ref": "..."}], "description": "..."}`. 40 descriptions are restored verbatim from the source document. The other four had no source description and were written by hand: `KeyCreateParameters.attributes`, `KeyUpdateParameters.attributes`, `KeyVaultError.error` and `Error.innererror`.

   **Reason**: Without it, the generated record fields have no documentation.

4. **Added descriptions to undocumented fields** (applied to `docs/spec/aligned_ballerina_openapi.json`)

   **Location**: `KeyOperationResult.value`, `KeyOperationsParameters.value`, `KeySignParameters.value`, `JsonWebKey.key_ops`, `KeyCreateParameters.key_ops`, `Contact.name`, `AdministratorDetails.last_name`

   **Original**: No description, or one of fewer than 10 characters (`Name`, `Last name`).

   **Updated**: Short descriptions, for example "The data to be encrypted, decrypted, wrapped or unwrapped, as a base64url-encoded value."

   **Reason**: Improves the generated API documentation.

5. **Added summaries to the managed storage-account operations** (applied to `docs/spec/aligned_ballerina_openapi.json`)

   **Location**: `GET /storage`, `GET|PUT|PATCH|DELETE /storage/{storageAccountName}`, `POST /storage/{storageAccountName}/regeneratekey`, `GET /storage/{storageAccountName}/sas`, `GET|PUT|PATCH|DELETE /storage/{storageAccountName}/sas/{sasDefinitionName}`

   **Original**: No `summary`.

   **Updated**: The first sentence of each operation's `description`, for example "Regenerates the specified key value for the given storage account."

   **Reason**: The summary becomes the generated method's doc comment.

6. **Renamed a misspelt schema**

   **Location**: `components.schemas`

   **Original**: `StorageAccountRegenerteKeyParameters`

   **Updated**: `StorageAccountRegenerateKeyParameters`, recorded in `docs/spec/ai-mappings.json`.

   **Reason**: Fixes the typo in the vendor schema name.

7. **Normalised operation IDs**

   **Location**: every operation's `operationId`, recorded in `docs/spec/ai-mappings.json`

   **Original**: PascalCase vendor IDs, for example `CreateKey` and `GetKeys`.

   **Updated**: camelCase, with the 14 collection reads renamed from `Get*` to `list*`: `listKeys`, `listKeyVersions`, `listDeletedKeys`, `listSecrets`, `listSecretVersions`, `listDeletedSecrets`, `listCertificates`, `listCertificateVersions`, `listCertificateIssuers`, `listDeletedCertificates`, `listStorageAccounts`, `listDeletedStorageAccounts`, `listSasDefinitions`, `listDeletedSasDefinitions`. All other IDs keep the vendor name, camelCased, for example `setSecret` and `wrapKey`.

   **Reason**: Separates reading one item (`get*`) from listing a collection (`list*`). Note that this renames 14 remote methods relative to `ballerinax/azure.keyvault` 1.6.1, for example `getKeys` to `listKeys`.

The specification declares no `servers`. The vault URL is supplied per vault (`https://<vault-name>.vault.azure.net`), so the generated client takes it as a required `serviceUrl` argument with no default, as the previously published connector did.

## OpenAPI cli command

The following command was used to generate the Ballerina client from the OpenAPI specification. The command should be executed from the repository root directory.

```bash
bal openapi -i docs/spec/aligned_ballerina_openapi.json --mode client --client-methods remote --license docs/license.txt -o ballerina
```
Note: The license year is 2026, as set in `docs/license.txt`.
