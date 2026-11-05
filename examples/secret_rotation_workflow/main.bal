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

// Rotates a secret: stores a new value as a new version, then disables every older
// version so that only the freshly rotated value remains usable.

import ballerina/http;
import ballerina/io;
import ballerinax/azure.keyvault;

configurable string keyVaultUrl = ?;
configurable string token = ?;
configurable string secretName = ?;
configurable string newSecretValue = ?;

const API_VERSION = "7.0";

public function main() returns error? {
    keyvault:Client keyVault = check new ({auth: {token}}, keyVaultUrl);

    // Step 1: write the new value. Key Vault stores it as a new version of the secret.
    keyvault:SecretBundle rotated = check keyVault->setSecret(secretName,
        {value: newSecretValue, contentType: "text/plain", tags: {"rotatedBy": "ballerina"}},
        apiVersion = API_VERSION);
    string currentId = rotated?.id ?: "";
    if currentId == "" {
        return error("Key Vault did not return an id for the new secret version");
    }
    string currentVersion = versionOf(currentId);
    io:println("Stored new version: ", currentVersion);

    // Step 2: list every version of the secret, following nextLink until the last page.
    keyvault:SecretListResult page = check keyVault->listSecretVersions(secretName,
        apiVersion = API_VERSION, maxresults = 25);
    keyvault:SecretItem[] versions = page?.value ?: [];
    string? nextLink = page?.nextLink;
    while nextLink is string && nextLink != "" {
        page = check nextPage(nextLink);
        keyvault:SecretItem[] more = page?.value ?: [];
        versions.push(...more);
        nextLink = page?.nextLink;
    }

    // Step 3: disable each older version that is still enabled.
    foreach keyvault:SecretItem item in versions {
        string? id = item?.id;
        if id is () {
            continue;
        }
        string version = versionOf(id);
        if version == currentVersion || item?.attributes?.enabled == false {
            continue;
        }
        keyvault:SecretBundle disabled = check keyVault->updateSecret(secretName, version,
            {attributes: {enabled: false}}, apiVersion = API_VERSION);
        io:println("Disabled version ", version, ": enabled=", disabled?.attributes?.enabled);
    }

    // Step 4: read the current version back to confirm the rotation.
    keyvault:SecretBundle current = check keyVault->getSecret(secretName, currentVersion,
        apiVersion = API_VERSION);
    io:println("Current version is enabled: ", current?.attributes?.enabled);
}

// A secret id has the form https://<vault>.vault.azure.net/secrets/<name>/<version>.
function versionOf(string id) returns string {
    int? slash = id.lastIndexOf("/");
    return slash is int ? id.substring(slash + 1) : id;
}

// Fetches the page a Key Vault `nextLink` points to. The link is an absolute URL that
// carries the skip token, and the client has no operation for it, so request it directly
// with the same bearer token.
function nextPage(string nextLink) returns keyvault:SecretListResult|error {
    int? scheme = nextLink.indexOf("://");
    int? pathStart = scheme is int ? nextLink.indexOf("/", scheme + 3) : ();
    if pathStart is () {
        return error(string `unexpected nextLink: ${nextLink}`);
    }
    http:Client pager = check new (nextLink.substring(0, pathStart), {auth: {token}});
    return pager->get(nextLink.substring(pathStart));
}
