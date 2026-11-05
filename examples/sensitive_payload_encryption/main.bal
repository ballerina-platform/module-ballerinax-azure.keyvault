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

// Protects a sensitive payload with an RSA key held in Key Vault: the key is created in
// the vault, the payload is encrypted with it, and the ciphertext is decrypted back. The
// private key never leaves the vault.

import ballerina/io;
import ballerina/lang.array;
import ballerinax/azure.keyvault;

configurable string keyVaultUrl = ?;
configurable string token = ?;
configurable string keyName = ?;

const API_VERSION = "7.0";

public function main() returns error? {
    keyvault:Client keyVault = check new ({auth: {token}}, keyVaultUrl);

    // Step 1: create an RSA key that may only be used for encryption and decryption.
    keyvault:KeyBundle created = check keyVault->createKey(keyName,
        {kty: "RSA", keySize: 2048, keyOps: ["encrypt", "decrypt"]}, apiVersion = API_VERSION);
    string kid = created?.key?.kid ?: "";
    if kid == "" {
        return error("Key Vault did not return a key identifier");
    }
    int? slash = kid.lastIndexOf("/");
    string keyVersion = slash is int ? kid.substring(slash + 1) : "";
    io:println("Created key: ", kid);

    // Step 2: encrypt. Key Vault expects the plaintext base64url-encoded.
    string plaintext = base64Url("card=4111111111111111;cvv=123".toBytes());
    keyvault:KeyOperationResult encrypted = check keyVault->encrypt(keyName, keyVersion,
        {alg: "RSA-OAEP-256", value: plaintext}, apiVersion = API_VERSION);
    string cipherText = encrypted?.value ?: "";
    if cipherText == "" {
        return error("encryption returned no ciphertext");
    }
    io:println("Ciphertext: ", cipherText);

    // Step 3: decrypt the ciphertext and check it round-trips.
    keyvault:KeyOperationResult decrypted = check keyVault->decrypt(keyName, keyVersion,
        {alg: "RSA-OAEP-256", value: cipherText}, apiVersion = API_VERSION);
    io:println("Round trip succeeded: ", decrypted?.value == plaintext);
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
