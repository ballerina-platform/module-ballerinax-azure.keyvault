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

import ballerina/os;
import ballerina/test;
import ballerina/time;

final boolean isLiveServer = os:getEnv("IS_LIVE_SERVER") == "true";
// The vault URL, e.g. https://myvault.vault.azure.net
final string serviceUrl = isLiveServer ? os:getEnv("AZURE_KEYVAULT_URL") : "http://localhost:9090";
// An Azure AD access token issued for the https://vault.azure.net resource
final string token = isLiveServer ? os:getEnv("AZURE_KEYVAULT_TOKEN") : "test_token";
// A storage account resource ID, required only by the storage-account tests
final string storageResourceId = isLiveServer ? os:getEnv("AZURE_STORAGE_RESOURCE_ID")
    : "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg-demo/providers/Microsoft.Storage/storageAccounts/mystorageacct";

const API_VERSION = "7.0";

final Client keyVault = check new ({auth: {token}}, serviceUrl);

// Live, a deleted name stays reserved until the soft-deleted object is purged, so a rerun
// that reused it would fail with 409 Conflict. Suffix live fixture names per run; the mock
// routes on path parameters, so its names stay as written.
final string runSuffix = isLiveServer ? string `-${time:utcNow()[0]}` : "";

isolated function fixture(string name) returns string => name + runSuffix;

// Each key/secret/certificate test works on its own uniquely named fixture, because test
// execution order is alphabetical and a shared fixture would be deleted under later tests.

isolated function keyVersionOf(KeyBundle bundle) returns string|error {
    string? kid = bundle?.key?.kid;
    if kid is () {
        return error("created key has no kid");
    }
    int? slash = kid.lastIndexOf("/");
    if slash is () {
        return error(string `unexpected kid: ${kid}`);
    }
    return kid.substring(slash + 1);
}

isolated function secretVersionOf(SecretBundle bundle) returns string|error {
    string? id = bundle?.id;
    if id is () {
        return error("created secret has no id");
    }
    int? slash = id.lastIndexOf("/");
    if slash is () {
        return error(string `unexpected secret id: ${id}`);
    }
    return id.substring(slash + 1);
}

isolated function newRsaKey(string name) returns KeyBundle|error {
    return keyVault->createKey(name, {kty: "RSA", keySize: 2048}, apiVersion = API_VERSION);
}

isolated function newSecret(string name) returns SecretBundle|error {
    return keyVault->setSecret(name, {value: "s3cr3t-value", contentType: "text/plain"},
        apiVersion = API_VERSION);
}

// ----- keys ----------------------------------------------------------------------------

@test:Config {groups: ["live_tests", "mock_tests"]}
function testCreateKey() returns error? {
    KeyBundle response = check newRsaKey(fixture("test-create-key"));
    test:assertTrue(response?.key?.kid !is ());
    test:assertEquals(response?.key?.kty, "RSA");
}

@test:Config {groups: ["live_tests", "mock_tests"]}
function testGetKey() returns error? {
    KeyBundle created = check newRsaKey(fixture("test-get-key"));
    string version = check keyVersionOf(created);
    KeyBundle response = check keyVault->getKey(fixture("test-get-key"), version, apiVersion = API_VERSION);
    test:assertTrue(response?.key?.kid !is ());
    test:assertEquals(response?.attributes?.enabled, true);
}

@test:Config {groups: ["live_tests", "mock_tests"]}
function testListKeys() returns error? {
    _ = check newRsaKey(fixture("test-list-keys"));
    KeyListResult response = check keyVault->listKeys(apiVersion = API_VERSION, maxresults = 25);
    KeyItem[] items = response?.value ?: [];
    test:assertTrue(items.length() > 0);
}

@test:Config {groups: ["live_tests", "mock_tests"]}
function testUpdateKey() returns error? {
    KeyBundle created = check newRsaKey(fixture("test-update-key"));
    string version = check keyVersionOf(created);
    KeyBundle response = check keyVault->updateKey(fixture("test-update-key"), version,
        {tags: {"purpose": "unit-test"}}, apiVersion = API_VERSION);
    test:assertEquals(response?.tags["purpose"], "unit-test");
}

@test:Config {groups: ["live_tests", "mock_tests"]}
function testDeleteKey() returns error? {
    KeyBundle created = check keyVault->createKey(fixture("test-delete-key"), {kty: "RSA", keySize: 2048},
        apiVersion = API_VERSION);
    test:assertTrue(created?.key?.kid !is ());
    DeletedKeyBundle response = check keyVault->deleteKey(fixture("test-delete-key"), apiVersion = API_VERSION);
    test:assertTrue(response?.recoveryId !is ());
    test:assertTrue(response?.deletedDate !is ());
}

@test:Config {groups: ["live_tests", "mock_tests"]}
function testBackupKey() returns error? {
    _ = check newRsaKey(fixture("test-backup-key"));
    BackupKeyResult response = check keyVault->backupKey(fixture("test-backup-key"), apiVersion = API_VERSION);
    test:assertTrue(response?.value !is ());
}

@test:Config {groups: ["mock_tests"]}
function testRestoreKey() returns error? {
    // Restoring a live backup needs the source key purged first; exercised against the mock only.
    _ = check newRsaKey(fixture("test-restore-key"));
    BackupKeyResult backup = check keyVault->backupKey(fixture("test-restore-key"), apiVersion = API_VERSION);
    string blob = backup?.value ?: "";
    test:assertNotEquals(blob, "");
    KeyBundle response = check keyVault->restoreKey({value: blob}, apiVersion = API_VERSION);
    test:assertTrue(response?.key?.kid !is ());
}

@test:Config {groups: ["live_tests", "mock_tests"]}
function testEncrypt() returns error? {
    KeyBundle created = check newRsaKey(fixture("test-encrypt-key"));
    string version = check keyVersionOf(created);
    KeyOperationResult response = check keyVault->encrypt(fixture("test-encrypt-key"), version,
        {alg: "RSA-OAEP", value: "NWI2NjA0NzQ4MDhhNGQ1OA"}, apiVersion = API_VERSION);
    test:assertTrue(response?.value !is ());
}

@test:Config {groups: ["live_tests", "mock_tests"]}
function testDecrypt() returns error? {
    KeyBundle created = check newRsaKey(fixture("test-decrypt-key"));
    string version = check keyVersionOf(created);
    KeyOperationResult encrypted = check keyVault->encrypt(fixture("test-decrypt-key"), version,
        {alg: "RSA-OAEP", value: "NWI2NjA0NzQ4MDhhNGQ1OA"}, apiVersion = API_VERSION);
    string cipherText = encrypted?.value ?: "";
    test:assertNotEquals(cipherText, "");
    KeyOperationResult response = check keyVault->decrypt(fixture("test-decrypt-key"), version,
        {alg: "RSA-OAEP", value: cipherText}, apiVersion = API_VERSION);
    test:assertEquals(response?.value, "NWI2NjA0NzQ4MDhhNGQ1OA");
}

@test:Config {groups: ["live_tests", "mock_tests"]}
function testSign() returns error? {
    KeyBundle created = check newRsaKey(fixture("test-sign-key"));
    string version = check keyVersionOf(created);
    // base64url-encoded SHA-256 digest
    KeyOperationResult response = check keyVault->sign(fixture("test-sign-key"), version,
        {alg: "RS256", value: "n4bQgYhMfWWaL-qgxVrQFaO_TxsrC4Is0V1sFbDwCgg"}, apiVersion = API_VERSION);
    test:assertTrue(response?.value !is ());
}

@test:Config {groups: ["live_tests", "mock_tests"]}
function testVerify() returns error? {
    string digest = "n4bQgYhMfWWaL-qgxVrQFaO_TxsrC4Is0V1sFbDwCgg";
    KeyBundle created = check newRsaKey(fixture("test-verify-key"));
    string version = check keyVersionOf(created);
    KeyOperationResult signature = check keyVault->sign(fixture("test-verify-key"), version,
        {alg: "RS256", value: digest}, apiVersion = API_VERSION);
    KeyVerifyResult response = check keyVault->verify(fixture("test-verify-key"), version,
        {alg: "RS256", digest, value: signature?.value ?: ""}, apiVersion = API_VERSION);
    test:assertEquals(response?.value, true);
}

@test:Config {groups: ["mock_tests"]}
function testListDeletedKeys() returns error? {
    _ = check newRsaKey(fixture("test-list-deleted-key"));
    _ = check keyVault->deleteKey(fixture("test-list-deleted-key"), apiVersion = API_VERSION);
    DeletedKeyListResult response = check keyVault->listDeletedKeys(apiVersion = API_VERSION);
    DeletedKeyItem[] items = response?.value ?: [];
    test:assertTrue(items.length() > 0);
}

@test:Config {groups: ["mock_tests"]}
function testGetDeletedKey() returns error? {
    // Live, a deleted key becomes readable only after an asynchronous soft-delete completes.
    _ = check newRsaKey(fixture("test-get-deleted-key"));
    _ = check keyVault->deleteKey(fixture("test-get-deleted-key"), apiVersion = API_VERSION);
    DeletedKeyBundle response = check keyVault->getDeletedKey(fixture("test-get-deleted-key"), apiVersion = API_VERSION);
    test:assertTrue(response?.scheduledPurgeDate !is ());
}

@test:Config {groups: ["mock_tests"]}
function testPurgeDeletedKey() returns error? {
    _ = check newRsaKey(fixture("test-purge-key"));
    _ = check keyVault->deleteKey(fixture("test-purge-key"), apiVersion = API_VERSION);
    error? response = keyVault->purgeDeletedKey(fixture("test-purge-key"), apiVersion = API_VERSION);
    test:assertTrue(response is ());
}

@test:Config {groups: ["mock_tests"]}
function testRecoverDeletedKey() returns error? {
    _ = check newRsaKey(fixture("test-recover-key"));
    _ = check keyVault->deleteKey(fixture("test-recover-key"), apiVersion = API_VERSION);
    KeyBundle response = check keyVault->recoverDeletedKey(fixture("test-recover-key"), apiVersion = API_VERSION);
    test:assertTrue(response?.key?.kid !is ());
}

// ----- secrets -------------------------------------------------------------------------

@test:Config {groups: ["live_tests", "mock_tests"]}
function testSetSecret() returns error? {
    SecretBundle response = check newSecret(fixture("test-set-secret"));
    test:assertEquals(response?.value, "s3cr3t-value");
    test:assertTrue(response?.id !is ());
}

@test:Config {groups: ["live_tests", "mock_tests"]}
function testGetSecret() returns error? {
    SecretBundle created = check newSecret(fixture("test-get-secret"));
    string version = check secretVersionOf(created);
    SecretBundle response = check keyVault->getSecret(fixture("test-get-secret"), version, apiVersion = API_VERSION);
    test:assertTrue(response?.value !is ());
}

@test:Config {groups: ["live_tests", "mock_tests"]}
function testListSecrets() returns error? {
    _ = check newSecret(fixture("test-list-secrets"));
    SecretListResult response = check keyVault->listSecrets(apiVersion = API_VERSION);
    SecretItem[] items = response?.value ?: [];
    test:assertTrue(items.length() > 0);
}

@test:Config {groups: ["live_tests", "mock_tests"]}
function testUpdateSecret() returns error? {
    SecretBundle created = check newSecret(fixture("test-update-secret"));
    string version = check secretVersionOf(created);
    SecretBundle response = check keyVault->updateSecret(fixture("test-update-secret"), version,
        {tags: {"owner": "integration-team"}}, apiVersion = API_VERSION);
    test:assertEquals(response?.tags["owner"], "integration-team");
}

@test:Config {groups: ["live_tests", "mock_tests"]}
function testDeleteSecret() returns error? {
    // Key Vault creates secrets with setSecret (PUT); there is no separate create operation.
    SecretBundle created = check keyVault->setSecret(fixture("test-delete-secret"),
        {value: "s3cr3t-value", contentType: "text/plain"}, apiVersion = API_VERSION);
    test:assertTrue(created?.id !is ());
    DeletedSecretBundle response = check keyVault->deleteSecret(fixture("test-delete-secret"), apiVersion = API_VERSION);
    test:assertTrue(response?.recoveryId !is ());
}

@test:Config {groups: ["live_tests", "mock_tests"]}
function testListSecretVersions() returns error? {
    _ = check newSecret(fixture("test-secret-versions"));
    SecretListResult response = check keyVault->listSecretVersions(fixture("test-secret-versions"), apiVersion = API_VERSION);
    SecretItem[] items = response?.value ?: [];
    test:assertTrue(items.length() > 0);
}

@test:Config {groups: ["mock_tests"]}
function testRecoverDeletedSecret() returns error? {
    _ = check newSecret(fixture("test-recover-secret"));
    _ = check keyVault->deleteSecret(fixture("test-recover-secret"), apiVersion = API_VERSION);
    SecretBundle response = check keyVault->recoverDeletedSecret(fixture("test-recover-secret"),
        apiVersion = API_VERSION);
    test:assertTrue(response?.id !is ());
}

// ----- certificates --------------------------------------------------------------------

isolated function newSelfSignedCertificate(string name) returns CertificateOperation|error {
    return keyVault->createCertificate(name, {
        policy: {
            keyProps: {exportable: true, kty: "RSA", keySize: 2048, reuseKey: false},
            secretProps: {contentType: "application/x-pkcs12"},
            x509Props: {subject: "CN=www.contoso.com", validityMonths: 12},
            issuer: {name: "Self"}
        }
    }, apiVersion = API_VERSION);
}

@test:Config {groups: ["live_tests", "mock_tests"]}
function testCreateCertificate() returns error? {
    CertificateOperation response = check newSelfSignedCertificate(fixture("test-create-cert"));
    test:assertTrue(response?.status !is ());
}

@test:Config {groups: ["mock_tests"]}
function testGetCertificate() returns error? {
    // Live, a certificate version is only readable once issuance completes.
    _ = check newSelfSignedCertificate(fixture("test-get-cert"));
    CertificateBundle response = check keyVault->getCertificate(fixture("test-get-cert"),
        "f60f2a4f8e5e4b3a9a2c7e2f9b0d4c11", apiVersion = API_VERSION);
    test:assertTrue(response?.cer !is ());
}

@test:Config {groups: ["live_tests", "mock_tests"]}
function testListCertificates() returns error? {
    _ = check newSelfSignedCertificate(fixture("test-list-certs"));
    CertificateListResult response = check keyVault->listCertificates(apiVersion = API_VERSION, includePending = true);
    CertificateItem[] items = response?.value ?: [];
    test:assertTrue(items.length() > 0);
}

@test:Config {groups: ["live_tests", "mock_tests"]}
function testGetCertificatePolicy() returns error? {
    _ = check newSelfSignedCertificate(fixture("test-cert-policy"));
    CertificatePolicy response = check keyVault->getCertificatePolicy(fixture("test-cert-policy"), apiVersion = API_VERSION);
    test:assertEquals(response?.issuer?.name, "Self");
}

@test:Config {groups: ["live_tests", "mock_tests"]}
function testDeleteCertificate() returns error? {
    CertificateOperation created = check keyVault->createCertificate(fixture("test-delete-cert"), {
        policy: {x509Props: {subject: "CN=delete.contoso.com", validityMonths: 12}, issuer: {name: "Self"}}
    }, apiVersion = API_VERSION);
    test:assertTrue(created?.id !is ());
    DeletedCertificateBundle response = check keyVault->deleteCertificate(fixture("test-delete-cert"),
        apiVersion = API_VERSION);
    test:assertTrue(response?.recoveryId !is ());
}

// ----- managed storage accounts --------------------------------------------------------

@test:Config {groups: ["mock_tests"]}
function testSetStorageAccount() returns error? {
    StorageBundle response = check keyVault->setStorageAccount("teststorageacct", {
        resourceId: storageResourceId,
        activeKeyName: "key1",
        autoRegenerateKey: true,
        regenerationPeriod: "P30D"
    }, apiVersion = API_VERSION);
    test:assertEquals(response?.activeKeyName, "key1");
}

@test:Config {groups: ["mock_tests"]}
function testGetStorageAccount() returns error? {
    StorageBundle response = check keyVault->getStorageAccount("mystorageacct", apiVersion = API_VERSION);
    test:assertTrue(response?.resourceId !is ());
}

@test:Config {groups: ["live_tests", "mock_tests"]}
function testListStorageAccounts() returns error? {
    StorageListResult response = check keyVault->listStorageAccounts(apiVersion = API_VERSION);
    test:assertTrue(response?.value !is ());
}
