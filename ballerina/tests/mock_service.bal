// Copyright (c) 2026, WSO2 LLC. (http://www.wso2.com).
//
// WSO2 LLC. licenses this file to you under the Apache License,
// Version 2.0 (the "License"); you may not use this file except
// in compliance with the License.
// You may obtain a copy of the License at
//
// http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing,
// software distributed under the License is distributed on an
// "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY
// KIND, either express or implied.  See the License for the
// specific language governing permissions and limitations
// under the License.

import ballerina/http;

listener http:Listener ep0 = new (9090);

service / on ep0 {
    # Deletes a certificate from a specified key vault.
    #
    # + certificateName - The name of the certificate
    # + apiVersion - Client API version
    # + return - returns can be any of following types 
    # http:Ok (The deleted certificate)
    # http:DefaultStatusCodeResponse (Key Vault error response describing why the operation failed.)
    resource function delete certificates/[string certificateName](@http:Query {name: "api-version"} string apiVersion) returns DeletedCertificateBundle|KeyVaultErrorDefault {
        DeletedCertificateBundle bundle = {id: "https://myvault.vault.azure.net/certificates/mycert/f60f2a4f8e5e4b3a9a2c7e2f9b0d4c11", kid: "https://myvault.vault.azure.net/keys/mycert/f60f2a4f8e5e4b3a9a2c7e2f9b0d4c11", sid: "https://myvault.vault.azure.net/secrets/mycert/f60f2a4f8e5e4b3a9a2c7e2f9b0d4c11", x5t: "fLi3U52HunIVNXubkEnf8tP6Wbo", cer: "MIICODCCAeagAwIBAgIQqHmpBAv+CY9IJFoUhlbziTAJBgUrDgMCHQUAMBYxFDASBgNVBAMTC1Jvb3QgQWdlbmN5", contentType: "application/x-pkcs12", attributes: {enabled: true, created: 1735689600, updated: 1735689600, nbf: 1735689000, exp: 1767225600, recoveryLevel: "Recoverable+Purgeable"}, policy: {id: "https://myvault.vault.azure.net/certificates/mycert/policy", keyProps: {exportable: true, kty: "RSA", keySize: 2048, reuseKey: false}, secretProps: {contentType: "application/x-pkcs12"}, x509Props: {subject: "CN=www.contoso.com", ekus: ["1.3.6.1.5.5.7.3.1"], keyUsage: ["digitalSignature", "keyEncipherment"], validityMonths: 12}, issuer: {name: "Self"}, attributes: {enabled: true, created: 1735689600, updated: 1735689600}}, recoveryId: "https://myvault.vault.azure.net/deletedcertificates/mycert", scheduledPurgeDate: 1743465600, deletedDate: 1735689600};
        return bundle;
    }

    # Permanently deletes the specified key.
    #
    # + keyName - The name of the key
    # + apiVersion - Client API version
    # + return - returns can be any of following types 
    # http:NoContent (No content, signaling that the key was permanently purged)
    # http:DefaultStatusCodeResponse (Key Vault error response describing why the operation failed.)
    resource function delete deletedkeys/[string keyName](@http:Query {name: "api-version"} string apiVersion) returns http:NoContent|KeyVaultErrorDefault {
        return http:NO_CONTENT;
    }

    # Deletes a key of any type from storage in Azure Key Vault.
    #
    # + keyName - The name of the key to delete
    # + apiVersion - Client API version
    # + return - returns can be any of following types 
    # http:Ok (The public part of the deleted key and deletion information on when the key will be purged)
    # http:DefaultStatusCodeResponse (Key Vault error response describing why the operation failed.)
    resource function delete keys/[string keyName](@http:Query {name: "api-version"} string apiVersion) returns DeletedKeyBundle|KeyVaultErrorDefault {
        DeletedKeyBundle bundle = {key: {kid: "https://myvault.vault.azure.net/keys/mykey/78deebed173b48e48f55abf87ed4cf71", kty: "RSA", keyOps: ["encrypt", "decrypt", "sign", "verify", "wrapKey", "unwrapKey"], n: "nKAwarTrOpzd1hhH4cQNdVTgRF-b0ubPD8ZNVf0UXjb62QuAk3Dn68ESThcF7SoDYRx2QVcfoMC9WCcuQUQDieJF", e: "AQAB"}, attributes: {enabled: true, created: 1735689600, updated: 1735689600, recoveryLevel: "Recoverable+Purgeable"}, tags: {"purpose": "unit-test"}, recoveryId: "https://myvault.vault.azure.net/deletedkeys/mykey", scheduledPurgeDate: 1743465600, deletedDate: 1735689600};
        return bundle;
    }

    # Deletes a secret from a specified key vault.
    #
    # + secretName - The name of the secret
    # + apiVersion - Client API version
    # + return - returns can be any of following types 
    # http:Ok (The deleted secret and information on when the secret will be deleted, and how to recover the deleted secret)
    # http:DefaultStatusCodeResponse (Key Vault error response describing why the operation failed.)
    resource function delete secrets/[string secretName](@http:Query {name: "api-version"} string apiVersion) returns DeletedSecretBundle|KeyVaultErrorDefault {
        DeletedSecretBundle bundle = {id: "https://myvault.vault.azure.net/secrets/mysecret/4387e9f3d6e14c459867679a90fd0f79", value: "mysecretvalue", contentType: "text/plain", attributes: {enabled: true, created: 1735689600, updated: 1735689600, recoveryLevel: "Recoverable+Purgeable"}, recoveryId: "https://myvault.vault.azure.net/deletedsecrets/mysecret", scheduledPurgeDate: 1743465600, deletedDate: 1735689600};
        return bundle;
    }

    # List certificates in a specified key vault
    #
    # + maxresults - Specifies the maximum number of results to return in a page. Setting maxresults to a value less than 1 or greater than 25 results in error response code 400 (Bad Request). If there are additional results to return, then the service returns a nextLink containing a skip token for pagination. In certain cases, the service might return fewer results than specified by maxresults (even 0 results) and also return a nextLink. Clients should not make any assumptions on the minimum number of results per page, and should enumerate all pages until the nextLink becomes null
    # + includePending - Specifies whether to include certificates which are not completely provisioned
    # + apiVersion - Client API version
    # + return - returns can be any of following types 
    # http:Ok (A response message containing a list of certificates along with a link to the next page of certificates)
    # http:DefaultStatusCodeResponse (Key Vault error response describing why the operation failed.)
    resource function get certificates(int:Signed32? maxresults, boolean? includePending, @http:Query {name: "api-version"} string apiVersion) returns CertificateListResult|KeyVaultErrorDefault {
        CertificateListResult result = {value: [{id: "https://myvault.vault.azure.net/certificates/mycert", x5t: "fLi3U52HunIVNXubkEnf8tP6Wbo", attributes: {enabled: true, created: 1735689600, updated: 1735689600, nbf: 1735689000, exp: 1767225600, recoveryLevel: "Recoverable+Purgeable"}}]};
        return result;
    }

    # Gets information about a certificate.
    #
    # + certificateName - The name of the certificate in the given vault
    # + certificateVersion - The version of the certificate
    # + apiVersion - Client API version
    # + return - returns can be any of following types 
    # http:Ok (The retrieved certificate)
    # http:DefaultStatusCodeResponse (Key Vault error response describing why the operation failed.)
    resource function get certificates/[string certificateName]/[string certificateVersion](@http:Query {name: "api-version"} string apiVersion) returns CertificateBundle|KeyVaultErrorDefault {
        CertificateBundle bundle = {id: "https://myvault.vault.azure.net/certificates/mycert/f60f2a4f8e5e4b3a9a2c7e2f9b0d4c11", kid: "https://myvault.vault.azure.net/keys/mycert/f60f2a4f8e5e4b3a9a2c7e2f9b0d4c11", sid: "https://myvault.vault.azure.net/secrets/mycert/f60f2a4f8e5e4b3a9a2c7e2f9b0d4c11", x5t: "fLi3U52HunIVNXubkEnf8tP6Wbo", cer: "MIICODCCAeagAwIBAgIQqHmpBAv+CY9IJFoUhlbziTAJBgUrDgMCHQUAMBYxFDASBgNVBAMTC1Jvb3QgQWdlbmN5", contentType: "application/x-pkcs12", attributes: {enabled: true, created: 1735689600, updated: 1735689600, nbf: 1735689000, exp: 1767225600, recoveryLevel: "Recoverable+Purgeable"}, policy: {id: "https://myvault.vault.azure.net/certificates/mycert/policy", keyProps: {exportable: true, kty: "RSA", keySize: 2048, reuseKey: false}, secretProps: {contentType: "application/x-pkcs12"}, x509Props: {subject: "CN=www.contoso.com", ekus: ["1.3.6.1.5.5.7.3.1"], keyUsage: ["digitalSignature", "keyEncipherment"], validityMonths: 12}, issuer: {name: "Self"}, attributes: {enabled: true, created: 1735689600, updated: 1735689600}}};
        return bundle;
    }

    # Lists the policy for a certificate.
    #
    # + certificateName - The name of the certificate in a given key vault
    # + apiVersion - Client API version
    # + return - returns can be any of following types 
    # http:Ok (The certificate policy)
    # http:DefaultStatusCodeResponse (Key Vault error response describing why the operation failed.)
    resource function get certificates/[string certificateName]/policy(@http:Query {name: "api-version"} string apiVersion) returns CertificatePolicy|KeyVaultErrorDefault {
        CertificatePolicy policy = {id: "https://myvault.vault.azure.net/certificates/mycert/policy", keyProps: {exportable: true, kty: "RSA", keySize: 2048, reuseKey: false}, secretProps: {contentType: "application/x-pkcs12"}, x509Props: {subject: "CN=www.contoso.com", ekus: ["1.3.6.1.5.5.7.3.1"], keyUsage: ["digitalSignature", "keyEncipherment"], validityMonths: 12}, issuer: {name: "Self"}, attributes: {enabled: true, created: 1735689600, updated: 1735689600}};
        return policy;
    }

    # Lists the deleted keys in the specified vault.
    #
    # + maxresults - Specifies the maximum number of results to return in a page. Setting maxresults to a value less than 1 or greater than 25 results in error response code 400 (Bad Request). If there are additional results to return, then the service returns a nextLink containing a skip token for pagination. In certain cases, the service might return fewer results than specified by maxresults (even 0 results) and also return a nextLink. Clients should not make any assumptions on the minimum number of results per page, and should enumerate all pages until the nextLink becomes null
    # + apiVersion - Client API version
    # + return - returns can be any of following types 
    # http:Ok (A response message containing a list of deleted keys in the vault along with a link to the next page of deleted keys)
    # http:DefaultStatusCodeResponse (Key Vault error response describing why the operation failed.)
    resource function get deletedkeys(int:Signed32? maxresults, @http:Query {name: "api-version"} string apiVersion) returns DeletedKeyListResult|KeyVaultErrorDefault {
        DeletedKeyListResult result = {value: [{kid: "https://myvault.vault.azure.net/keys/mykey", attributes: {enabled: true, created: 1735689600, updated: 1735689600, recoveryLevel: "Recoverable+Purgeable"}, recoveryId: "https://myvault.vault.azure.net/deletedkeys/mykey", scheduledPurgeDate: 1743465600, deletedDate: 1735689600}]};
        return result;
    }

    # Gets the public part of a deleted key.
    #
    # + keyName - The name of the key
    # + apiVersion - Client API version
    # + return - returns can be any of following types 
    # http:Ok (A DeletedKeyBundle consisting of a WebKey plus its Attributes and deletion information)
    # http:DefaultStatusCodeResponse (Key Vault error response describing why the operation failed.)
    resource function get deletedkeys/[string keyName](@http:Query {name: "api-version"} string apiVersion) returns DeletedKeyBundle|KeyVaultErrorDefault {
        DeletedKeyBundle bundle = {key: {kid: "https://myvault.vault.azure.net/keys/mykey/78deebed173b48e48f55abf87ed4cf71", kty: "RSA", keyOps: ["encrypt", "decrypt", "sign", "verify", "wrapKey", "unwrapKey"], n: "nKAwarTrOpzd1hhH4cQNdVTgRF-b0ubPD8ZNVf0UXjb62QuAk3Dn68ESThcF7SoDYRx2QVcfoMC9WCcuQUQDieJF", e: "AQAB"}, attributes: {enabled: true, created: 1735689600, updated: 1735689600, recoveryLevel: "Recoverable+Purgeable"}, tags: {"purpose": "unit-test"}, recoveryId: "https://myvault.vault.azure.net/deletedkeys/mykey", scheduledPurgeDate: 1743465600, deletedDate: 1735689600};
        return bundle;
    }

    # List keys in the specified vault.
    #
    # + maxresults - Specifies the maximum number of results to return in a page. Setting maxresults to a value less than 1 or greater than 25 results in error response code 400 (Bad Request). If there are additional results to return, then the service returns a nextLink containing a skip token for pagination. In certain cases, the service might return fewer results than specified by maxresults (even 0 results) and also return a nextLink. Clients should not make any assumptions on the minimum number of results per page, and should enumerate all pages until the nextLink becomes null
    # + apiVersion - Client API version
    # + return - returns can be any of following types 
    # http:Ok (A response message containing a list of keys in the vault along with a link to the next page of keys)
    # http:DefaultStatusCodeResponse (Key Vault error response describing why the operation failed.)
    resource function get keys(int:Signed32? maxresults, @http:Query {name: "api-version"} string apiVersion) returns KeyListResult|KeyVaultErrorDefault {
        KeyListResult result = {value: [{kid: "https://myvault.vault.azure.net/keys/mykey", attributes: {enabled: true, created: 1735689600, updated: 1735689600, recoveryLevel: "Recoverable+Purgeable"}, tags: {"purpose": "unit-test"}}, {kid: "https://myvault.vault.azure.net/keys/signingkey", attributes: {enabled: true, created: 1735689600, updated: 1735689600, recoveryLevel: "Recoverable+Purgeable"}}]};
        return result;
    }

    # Gets the public part of a stored key.
    #
    # + keyName - The name of the key to get
    # + keyVersion - Adding the version parameter retrieves a specific version of a key
    # + apiVersion - Client API version
    # + return - returns can be any of following types 
    # http:Ok (A key bundle containing the key and its attributes)
    # http:DefaultStatusCodeResponse (Key Vault error response describing why the operation failed.)
    resource function get keys/[string keyName]/[string keyVersion](@http:Query {name: "api-version"} string apiVersion) returns KeyBundle|KeyVaultErrorDefault {
        KeyBundle bundle = {key: {kid: "https://myvault.vault.azure.net/keys/mykey/78deebed173b48e48f55abf87ed4cf71", kty: "RSA", keyOps: ["encrypt", "decrypt", "sign", "verify", "wrapKey", "unwrapKey"], n: "nKAwarTrOpzd1hhH4cQNdVTgRF-b0ubPD8ZNVf0UXjb62QuAk3Dn68ESThcF7SoDYRx2QVcfoMC9WCcuQUQDieJF", e: "AQAB"}, attributes: {enabled: true, created: 1735689600, updated: 1735689600, recoveryLevel: "Recoverable+Purgeable"}, tags: {"purpose": "unit-test"}};
        return bundle;
    }

    # List secrets in a specified key vault.
    #
    # + maxresults - Specifies the maximum number of results to return in a page. Setting maxresults to a value less than 1 or greater than 25 results in error response code 400 (Bad Request). If there are additional results to return, then the service returns a nextLink containing a skip token for pagination. In certain cases, the service might return fewer results than specified by maxresults (even 0 results) and also return a nextLink. Clients should not make any assumptions on the minimum number of results per page, and should enumerate all pages until the nextLink becomes null
    # + apiVersion - Client API version
    # + return - returns can be any of following types 
    # http:Ok (A response message containing a list of secrets in the vault along with a link to the next page of secrets)
    # http:DefaultStatusCodeResponse (Key Vault error response describing why the operation failed.)
    resource function get secrets(int:Signed32? maxresults, @http:Query {name: "api-version"} string apiVersion) returns SecretListResult|KeyVaultErrorDefault {
        SecretListResult result = {value: [{id: "https://myvault.vault.azure.net/secrets/mysecret", contentType: "text/plain", attributes: {enabled: true, created: 1735689600, updated: 1735689600, recoveryLevel: "Recoverable+Purgeable"}}]};
        return result;
    }

    # Get a specified secret from a given key vault.
    #
    # + secretName - The name of the secret
    # + secretVersion - The version of the secret
    # + apiVersion - Client API version
    # + return - returns can be any of following types 
    # http:Ok (The retrieved secret)
    # http:DefaultStatusCodeResponse (Key Vault error response describing why the operation failed.)
    resource function get secrets/[string secretName]/[string secretVersion](@http:Query {name: "api-version"} string apiVersion) returns SecretBundle|KeyVaultErrorDefault {
        SecretBundle bundle = {id: "https://myvault.vault.azure.net/secrets/mysecret/4387e9f3d6e14c459867679a90fd0f79", value: "mysecretvalue", contentType: "text/plain", attributes: {enabled: true, created: 1735689600, updated: 1735689600, recoveryLevel: "Recoverable+Purgeable"}};
        return bundle;
    }

    # List all versions of the specified secret.
    #
    # + secretName - The name of the secret
    # + maxresults - Specifies the maximum number of results to return in a page. Setting maxresults to a value less than 1 or greater than 25 results in error response code 400 (Bad Request). If there are additional results to return, then the service returns a nextLink containing a skip token for pagination. In certain cases, the service might return fewer results than specified by maxresults (even 0 results) and also return a nextLink. Clients should not make any assumptions on the minimum number of results per page, and should enumerate all pages until the nextLink becomes null
    # + apiVersion - Client API version
    # + return - returns can be any of following types 
    # http:Ok (A response message containing a list of secrets along with a link to the next page of secrets)
    # http:DefaultStatusCodeResponse (Key Vault error response describing why the operation failed.)
    resource function get secrets/[string secretName]/versions(int:Signed32? maxresults, @http:Query {name: "api-version"} string apiVersion) returns SecretListResult|KeyVaultErrorDefault {
        SecretListResult result = {value: [{id: "https://myvault.vault.azure.net/secrets/mysecret/4387e9f3d6e14c459867679a90fd0f79", contentType: "text/plain", attributes: {enabled: true, created: 1735689600, updated: 1735689600, recoveryLevel: "Recoverable+Purgeable"}}, {id: "https://myvault.vault.azure.net/secrets/mysecret/1b1c4a9a3cb04dfc9d6a6f0e2f2c5b10", contentType: "text/plain", attributes: {enabled: true, created: 1735689600, updated: 1735689600, recoveryLevel: "Recoverable+Purgeable"}}]};
        return result;
    }

    # List storage accounts managed by the specified key vault.
    #
    # + maxresults - Specifies the maximum number of results to return in a page. Setting maxresults to a value less than 1 or greater than 25 results in error response code 400 (Bad Request). If there are additional results to return, then the service returns a nextLink containing a skip token for pagination. In certain cases, the service might return fewer results than specified by maxresults (even 0 results) and also return a nextLink. Clients should not make any assumptions on the minimum number of results per page, and should enumerate all pages until the nextLink becomes null
    # + apiVersion - Client API version
    # + return - returns can be any of following types 
    # http:Ok (A response message containing a list of storage accounts along with a link to the next page of storage accounts)
    # http:DefaultStatusCodeResponse (Key Vault error response describing why the operation failed.)
    resource function get storage(int:Signed32? maxresults, @http:Query {name: "api-version"} string apiVersion) returns StorageListResult|KeyVaultErrorDefault {
        StorageListResult result = {value: [{id: "https://myvault.vault.azure.net/storage/mystorageacct", resourceId: "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg-demo/providers/Microsoft.Storage/storageAccounts/mystorageacct", attributes: {enabled: true, created: 1735689600, updated: 1735689600, recoveryLevel: "Recoverable+Purgeable"}}]};
        return result;
    }

    # Gets information about a specified storage account.
    #
    # + storageAccountName - The name of the storage account
    # + apiVersion - Client API version
    # + return - returns can be any of following types 
    # http:Ok (The retrieved storage account)
    # http:DefaultStatusCodeResponse (Key Vault error response describing why the operation failed.)
    resource function get storage/[string storageAccountName](@http:Query {name: "api-version"} string apiVersion) returns StorageBundle|KeyVaultErrorDefault {
        StorageBundle bundle = {id: "https://myvault.vault.azure.net/storage/mystorageacct", resourceId: "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg-demo/providers/Microsoft.Storage/storageAccounts/mystorageacct", activeKeyName: "key1", autoRegenerateKey: true, regenerationPeriod: "P30D", attributes: {enabled: true, created: 1735689600, updated: 1735689600, recoveryLevel: "Recoverable+Purgeable"}};
        return bundle;
    }

    # The update key operation changes specified attributes of a stored key and can be applied to any key type and key version stored in Azure Key Vault.
    #
    # + keyName - The name of key to update
    # + keyVersion - The version of the key to update
    # + apiVersion - Client API version
    # + payload - The parameters of the key to update 
    # + return - returns can be any of following types 
    # http:Ok (The updated key)
    # http:DefaultStatusCodeResponse (Key Vault error response describing why the operation failed.)
    resource function patch keys/[string keyName]/[string keyVersion](@http:Query {name: "api-version"} string apiVersion, @http:Payload KeyUpdateParameters payload) returns KeyBundle|KeyVaultErrorDefault {
        KeyBundle bundle = {key: {kid: "https://myvault.vault.azure.net/keys/mykey/78deebed173b48e48f55abf87ed4cf71", kty: "RSA", keyOps: ["encrypt", "decrypt", "sign", "verify", "wrapKey", "unwrapKey"], n: "nKAwarTrOpzd1hhH4cQNdVTgRF-b0ubPD8ZNVf0UXjb62QuAk3Dn68ESThcF7SoDYRx2QVcfoMC9WCcuQUQDieJF", e: "AQAB"}, attributes: {enabled: true, created: 1735689600, updated: 1735689600, recoveryLevel: "Recoverable+Purgeable"}, tags: payload.tags ?: {"purpose": "unit-test"}};
        return bundle;
    }

    # Updates the attributes associated with a specified secret in a given key vault.
    #
    # + secretName - The name of the secret
    # + secretVersion - The version of the secret
    # + apiVersion - Client API version
    # + payload - The parameters for update secret operation 
    # + return - returns can be any of following types 
    # http:Ok (The updated secret)
    # http:DefaultStatusCodeResponse (Key Vault error response describing why the operation failed.)
    resource function patch secrets/[string secretName]/[string secretVersion](@http:Query {name: "api-version"} string apiVersion, @http:Payload SecretUpdateParameters payload) returns SecretBundle|KeyVaultErrorDefault {
        SecretBundle bundle = {id: "https://myvault.vault.azure.net/secrets/mysecret/4387e9f3d6e14c459867679a90fd0f79", value: "mysecretvalue", contentType: "text/plain", attributes: {enabled: true, created: 1735689600, updated: 1735689600, recoveryLevel: "Recoverable+Purgeable"}, tags: payload.tags ?: {}};
        return bundle;
    }

    # Creates a new certificate.
    #
    # + certificateName - The name of the certificate
    # + apiVersion - Client API version
    # + payload - The parameters to create a certificate 
    # + return - returns can be any of following types 
    # http:Accepted (Created certificate bundle)
    # http:DefaultStatusCodeResponse (Key Vault error response describing why the operation failed.)
    resource function post certificates/[string certificateName]/create(@http:Query {name: "api-version"} string apiVersion, @http:Payload CertificateCreateParameters payload) returns CertificateOperationAccepted|KeyVaultErrorDefault {
        return <CertificateOperationAccepted>{body: {id: "https://myvault.vault.azure.net/certificates/mycert/pending", issuer: {name: "Self"}, csr: "MIICoTCCAYkCAQAwGjEYMBYGA1UEAxMPd3d3LmNvbnRvc28uY29t", cancellationRequested: false, status: "inProgress", statusDetails: "Pending certificate created. Certificate request is in progress.", requestId: "a2ce9a0a4bd0460fa0c8a1b3e6fa7e2c"}};
    }

    # Recovers the deleted key to its latest version.
    #
    # + keyName - The name of the deleted key
    # + apiVersion - Client API version
    # + return - returns can be any of following types 
    # http:Ok (A Key bundle of the original key and its attributes)
    # http:DefaultStatusCodeResponse (Key Vault error response describing why the operation failed.)
    resource function post deletedkeys/[string keyName]/recover(@http:Query {name: "api-version"} string apiVersion) returns KeyBundleOk|KeyVaultErrorDefault {
        return <KeyBundleOk>{body: {key: {kid: "https://myvault.vault.azure.net/keys/mykey/78deebed173b48e48f55abf87ed4cf71", kty: "RSA", keyOps: ["encrypt", "decrypt", "sign", "verify", "wrapKey", "unwrapKey"], n: "nKAwarTrOpzd1hhH4cQNdVTgRF-b0ubPD8ZNVf0UXjb62QuAk3Dn68ESThcF7SoDYRx2QVcfoMC9WCcuQUQDieJF", e: "AQAB"}, attributes: {enabled: true, created: 1735689600, updated: 1735689600, recoveryLevel: "Recoverable+Purgeable"}, tags: {"purpose": "unit-test"}}};
    }

    # Recovers the deleted secret to the latest version.
    #
    # + secretName - The name of the deleted secret
    # + apiVersion - Client API version
    # + return - returns can be any of following types 
    # http:Ok (A Secret bundle of the original secret and its attributes)
    # http:DefaultStatusCodeResponse (Key Vault error response describing why the operation failed.)
    resource function post deletedsecrets/[string secretName]/recover(@http:Query {name: "api-version"} string apiVersion) returns SecretBundleOk|KeyVaultErrorDefault {
        return <SecretBundleOk>{body: {id: "https://myvault.vault.azure.net/secrets/mysecret/4387e9f3d6e14c459867679a90fd0f79", value: "mysecretvalue", contentType: "text/plain", attributes: {enabled: true, created: 1735689600, updated: 1735689600, recoveryLevel: "Recoverable+Purgeable"}}};
    }

    # Decrypts a single block of encrypted data.
    #
    # + keyName - The name of the key
    # + keyVersion - The version of the key
    # + apiVersion - Client API version
    # + payload - The parameters for the decryption operation 
    # + return - returns can be any of following types 
    # http:Ok (The decryption result)
    # http:DefaultStatusCodeResponse (Key Vault error response describing why the operation failed.)
    resource function post keys/[string keyName]/[string keyVersion]/decrypt(@http:Query {name: "api-version"} string apiVersion, @http:Payload KeyOperationsParameters payload) returns KeyOperationResultOk|KeyVaultErrorDefault {
        return <KeyOperationResultOk>{body: {kid: "https://myvault.vault.azure.net/keys/mykey/78deebed173b48e48f55abf87ed4cf71", value: "NWI2NjA0NzQ4MDhhNGQ1OA"}};
    }

    # Encrypts an arbitrary sequence of bytes using an encryption key that is stored in a key vault.
    #
    # + keyName - The name of the key
    # + keyVersion - The version of the key
    # + apiVersion - Client API version
    # + payload - The parameters for the encryption operation 
    # + return - returns can be any of following types 
    # http:Ok (The encryption result)
    # http:DefaultStatusCodeResponse (Key Vault error response describing why the operation failed.)
    resource function post keys/[string keyName]/[string keyVersion]/encrypt(@http:Query {name: "api-version"} string apiVersion, @http:Payload KeyOperationsParameters payload) returns KeyOperationResultOk|KeyVaultErrorDefault {
        return <KeyOperationResultOk>{body: {kid: "https://myvault.vault.azure.net/keys/mykey/78deebed173b48e48f55abf87ed4cf71", value: "b9D8vxi7hKzQ1FpSLz3JWm4Y2Xo8qW0nZfRk5sUeTcA"}};
    }

    # Creates a signature from a digest using the specified key.
    #
    # + keyName - The name of the key
    # + keyVersion - The version of the key
    # + apiVersion - Client API version
    # + payload - The parameters for the signing operation 
    # + return - returns can be any of following types 
    # http:Ok (The signature value)
    # http:DefaultStatusCodeResponse (Key Vault error response describing why the operation failed.)
    resource function post keys/[string keyName]/[string keyVersion]/sign(@http:Query {name: "api-version"} string apiVersion, @http:Payload KeySignParameters payload) returns KeyOperationResultOk|KeyVaultErrorDefault {
        return <KeyOperationResultOk>{body: {kid: "https://myvault.vault.azure.net/keys/mykey/78deebed173b48e48f55abf87ed4cf71", value: "aKFG8NXcfTzqyR44rW42484K_zZI_T7zZuebvWuNgAoEI1gXYmxrshp42CunSmmu4oqo4-IrCikPkNIBkHXnAW2cv03Ad0UpwXhVfepK8zzDBaJPMKVGS-ZRz8CshEyGDKaLlb3J3zEkXpM3ToHqdTDTYGKJxRuNvvPhodDqaCo"}};
    }

    # Verifies a signature using a specified key.
    #
    # + keyName - The name of the key
    # + keyVersion - The version of the key
    # + apiVersion - Client API version
    # + payload - The parameters for verify operations 
    # + return - returns can be any of following types 
    # http:Ok (The verification result)
    # http:DefaultStatusCodeResponse (Key Vault error response describing why the operation failed.)
    resource function post keys/[string keyName]/[string keyVersion]/verify(@http:Query {name: "api-version"} string apiVersion, @http:Payload KeyVerifyParameters payload) returns KeyVerifyResultOk|KeyVaultErrorDefault {
        return <KeyVerifyResultOk>{body: {value: true}};
    }

    # Requests that a backup of the specified key be downloaded to the client.
    #
    # + keyName - The name of the key
    # + apiVersion - Client API version
    # + return - returns can be any of following types 
    # http:Ok (The backup blob containing the backed up key)
    # http:DefaultStatusCodeResponse (Key Vault error response describing why the operation failed.)
    resource function post keys/[string keyName]/backup(@http:Query {name: "api-version"} string apiVersion) returns BackupKeyResultOk|KeyVaultErrorDefault {
        return <BackupKeyResultOk>{body: {value: "JkF6dXJlS2V5VmF1bHRLZXlCYWNrdXBWMS5taWNyb3NvZnQuY29tZXlKcmFXUWlPaUkwTXpnNU1UTX"}};
    }

    # Creates a new key, stores it, then returns key parameters and attributes to the client.
    #
    # + keyName - The name for the new key. The system will generate the version name for the new key
    # + apiVersion - Client API version
    # + payload - The parameters to create a key 
    # + return - returns can be any of following types 
    # http:Ok (A key bundle containing the result of the create key request)
    # http:DefaultStatusCodeResponse (Key Vault error response describing why the operation failed.)
    resource function post keys/[string keyName]/create(@http:Query {name: "api-version"} string apiVersion, @http:Payload KeyCreateParameters payload) returns KeyBundleOk|KeyVaultErrorDefault {
        return <KeyBundleOk>{body: {key: {kid: "https://myvault.vault.azure.net/keys/mykey/78deebed173b48e48f55abf87ed4cf71", kty: "RSA", keyOps: ["encrypt", "decrypt", "sign", "verify", "wrapKey", "unwrapKey"], n: "nKAwarTrOpzd1hhH4cQNdVTgRF-b0ubPD8ZNVf0UXjb62QuAk3Dn68ESThcF7SoDYRx2QVcfoMC9WCcuQUQDieJF", e: "AQAB"}, attributes: {enabled: true, created: 1735689600, updated: 1735689600, recoveryLevel: "Recoverable+Purgeable"}, tags: {"purpose": "unit-test"}}};
    }

    # Restores a backed up key to a vault.
    #
    # + apiVersion - Client API version
    # + payload - The parameters to restore the key 
    # + return - returns can be any of following types 
    # http:Ok (Restored key bundle in the vault)
    # http:DefaultStatusCodeResponse (Key Vault error response describing why the operation failed.)
    resource function post keys/restore(@http:Query {name: "api-version"} string apiVersion, @http:Payload KeyRestoreParameters payload) returns KeyBundleOk|KeyVaultErrorDefault {
        return <KeyBundleOk>{body: {key: {kid: "https://myvault.vault.azure.net/keys/mykey/78deebed173b48e48f55abf87ed4cf71", kty: "RSA", keyOps: ["encrypt", "decrypt", "sign", "verify", "wrapKey", "unwrapKey"], n: "nKAwarTrOpzd1hhH4cQNdVTgRF-b0ubPD8ZNVf0UXjb62QuAk3Dn68ESThcF7SoDYRx2QVcfoMC9WCcuQUQDieJF", e: "AQAB"}, attributes: {enabled: true, created: 1735689600, updated: 1735689600, recoveryLevel: "Recoverable+Purgeable"}, tags: {"purpose": "unit-test"}}};
    }

    # Sets a secret in a specified key vault.
    #
    # + secretName - The name of the secret
    # + apiVersion - Client API version
    # + payload - The parameters for setting the secret 
    # + return - returns can be any of following types 
    # http:Ok (A secret bundle containing the result of the set secret request)
    # http:DefaultStatusCodeResponse (Key Vault error response describing why the operation failed.)
    resource function put secrets/[string secretName](@http:Query {name: "api-version"} string apiVersion, @http:Payload SecretSetParameters payload) returns SecretBundle|KeyVaultErrorDefault {
        SecretBundle bundle = {id: "https://myvault.vault.azure.net/secrets/mysecret/4387e9f3d6e14c459867679a90fd0f79", value: payload.value, contentType: "text/plain", attributes: {enabled: true, created: 1735689600, updated: 1735689600, recoveryLevel: "Recoverable+Purgeable"}};
        return bundle;
    }

    # Creates or updates a new storage account.
    #
    # + storageAccountName - The name of the storage account
    # + apiVersion - Client API version
    # + payload - The parameters to create a storage account 
    # + return - returns can be any of following types 
    # http:Ok (The created storage account)
    # http:DefaultStatusCodeResponse (Key Vault error response describing why the operation failed.)
    resource function put storage/[string storageAccountName](@http:Query {name: "api-version"} string apiVersion, @http:Payload StorageAccountCreateParameters payload) returns StorageBundle|KeyVaultErrorDefault {
        StorageBundle bundle = {id: "https://myvault.vault.azure.net/storage/mystorageacct", resourceId: payload.resourceId, activeKeyName: payload.activeKeyName, autoRegenerateKey: payload.autoRegenerateKey, regenerationPeriod: payload.regenerationPeriod ?: "P30D", attributes: {enabled: true, created: 1735689600, updated: 1735689600, recoveryLevel: "Recoverable+Purgeable"}};
        return bundle;
    }
}

// Service-mode response types. `bal openapi --mode client` collapses 4XX/5XX
// to `error` and never emits these, so they are defined here for the mock only.
public type BackupKeyResultOk record {|
    *http:Ok;
    BackupKeyResult body;
|};

public type CertificateOperationAccepted record {|
    *http:Accepted;
    CertificateOperation body;
|};

public type KeyBundleOk record {|
    *http:Ok;
    KeyBundle body;
|};

public type KeyOperationResultOk record {|
    *http:Ok;
    KeyOperationResult body;
|};

public type KeyVaultErrorDefault record {|
    *http:DefaultStatusCodeResponse;
    KeyVaultError body;
|};

public type KeyVerifyResultOk record {|
    *http:Ok;
    KeyVerifyResult body;
|};

public type SecretBundleOk record {|
    *http:Ok;
    SecretBundle body;
|};

# The key vault error exception
public type KeyVaultError record {
    # The Key Vault server error.
    Error 'error?;
};
