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

// Signs a document with a key stored in Key Vault and verifies the signature. The
// document is hashed locally; only the SHA-256 digest is sent to the vault.

import ballerina/crypto;
import ballerina/http;
import ballerina/io;
import ballerina/lang.array;
import ballerinax/azure.keyvault;

configurable string keyVaultUrl = ?;
configurable string token = ?;
// An existing RSA key permitted to sign and verify
configurable string signingKeyName = ?;
configurable string document = ?;

const API_VERSION = "7.0";

public function main() returns error? {
    keyvault:Client keyVault = check new ({auth: {token}}, keyVaultUrl);

    // Step 1: list every version of the signing key, following nextLink until the last page.
    keyvault:KeyListResult page = check keyVault->listKeyVersions(signingKeyName,
        apiVersion = API_VERSION);
    keyvault:KeyItem[] versions = page?.value ?: [];
    string? nextLink = page?.nextLink;
    while nextLink is string && nextLink != "" {
        page = check nextPage(nextLink);
        keyvault:KeyItem[] more = page?.value ?: [];
        versions.push(...more);
        nextLink = page?.nextLink;
    }

    // Step 2: pick the newest enabled version.
    string keyVersion = "";
    int newest = 0;
    foreach keyvault:KeyItem item in versions {
        int created = item?.attributes?.created ?: 0;
        string? kid = item?.kid;
        if kid is string && item?.attributes?.enabled == true && created >= newest {
            int? slash = kid.lastIndexOf("/");
            keyVersion = slash is int ? kid.substring(slash + 1) : "";
            newest = created;
        }
    }
    if keyVersion == "" {
        return error(string `no enabled version of key '${signingKeyName}' found`);
    }

    // Step 3: confirm the key type before choosing an algorithm.
    keyvault:KeyBundle signingKey = check keyVault->getKey(signingKeyName, keyVersion,
        apiVersion = API_VERSION);
    io:println("Signing with ", signingKey?.key?.kid, " (", signingKey?.key?.kty, ")");

    // Step 4: sign the SHA-256 digest of the document.
    string digest = base64Url(crypto:hashSha256(document.toBytes()));
    keyvault:KeyOperationResult signature = check keyVault->sign(signingKeyName, keyVersion,
        {alg: "RS256", value: digest}, apiVersion = API_VERSION);
    string signatureValue = signature?.value ?: "";
    io:println("Signature: ", signatureValue);

    // Step 5: verify the signature against the same digest.
    keyvault:KeyVerifyResult result = check keyVault->verify(signingKeyName, keyVersion,
        {alg: "RS256", digest, value: signatureValue}, apiVersion = API_VERSION);
    io:println("Signature valid: ", result?.value);
}

// base64url without padding, as used throughout the Key Vault cryptography API.
function base64Url(byte[] data) returns string {
    string b64 = array:toBase64(data);
    string out = "";
    foreach string:Char c in b64 {
        if c == "+" {
            out += "-";
        } else if c == "/" {
            out += "_";
        } else if c != "=" {
            out += c;
        }
    }
    return out;
}

// Fetches the page a Key Vault `nextLink` points to. The link is an absolute URL that
// carries the skip token, and the client has no operation for it, so request it directly
// with the same bearer token.
function nextPage(string nextLink) returns keyvault:KeyListResult|error {
    int? scheme = nextLink.indexOf("://");
    int? pathStart = scheme is int ? nextLink.indexOf("/", scheme + 3) : ();
    if pathStart is () {
        return error(string `unexpected nextLink: ${nextLink}`);
    }
    http:Client pager = check new (nextLink.substring(0, pathStart), {auth: {token}});
    return pager->get(nextLink.substring(pathStart));
}
