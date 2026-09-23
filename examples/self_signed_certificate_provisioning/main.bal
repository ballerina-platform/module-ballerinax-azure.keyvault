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

// Provisions a self-signed TLS certificate in Key Vault, waits for issuance to finish,
// and then reads back the policy and the issued versions.

import ballerina/io;
import ballerina/lang.runtime;
import ballerinax/azure.keyvault;

configurable string keyVaultUrl = ?;
configurable string token = ?;
configurable string certificateName = ?;
configurable string subject = ?;

const API_VERSION = "7.0";

public function main() returns error? {
    keyvault:Client keyVault = check new ({auth: {token}}, keyVaultUrl);

    // Step 1: request a self-signed certificate valid for 12 months.
    keyvault:CertificateOperation operation = check keyVault->createCertificate(certificateName, {
        policy: {
            keyProps: {exportable: true, kty: "RSA", keySize: 2048, reuseKey: false},
            secretProps: {contentType: "application/x-pkcs12"},
            x509Props: {subject, validityMonths: 12, keyUsage: ["digitalSignature", "keyEncipherment"]},
            issuer: {name: "Self"}
        }
    }, apiVersion = API_VERSION);
    io:println("Issuance status: ", operation?.status);

    // Step 2: poll the pending operation until issuance completes.
    int attempts = 0;
    while operation?.status == "inProgress" && attempts < 10 {
        runtime:sleep(3);
        operation = check keyVault->getCertificateOperation(certificateName, apiVersion = API_VERSION);
        attempts += 1;
    }
    if operation?.status != "completed" {
        return error(string `certificate issuance did not complete: ${operation?.status ?: "unknown"}`);
    }

    // Step 3: read the policy the certificate was issued under.
    keyvault:CertificatePolicy policy = check keyVault->getCertificatePolicy(certificateName,
        apiVersion = API_VERSION);
    io:println("Subject: ", policy?.x509Props?.subject, ", issuer: ", policy?.issuer?.name);

    // Step 4: list the issued versions.
    keyvault:CertificateListResult versions = check keyVault->listCertificateVersions(certificateName,
        apiVersion = API_VERSION);
    foreach keyvault:CertificateItem item in versions?.value ?: [] {
        io:println("Version ", item?.id, " expires at ", item?.attributes?.exp);
    }
}
