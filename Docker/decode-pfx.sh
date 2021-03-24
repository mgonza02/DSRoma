#!/bin/bash
CERT_NAME=$1
CER_PWD = $2
openssl pkcx12 -in "${CERT_NAME}.pfx" -out "${CERT_NAME}.cer" -passin:"${CERT_NAME}"  -nodes 
openssl pkcx12 -in "${CERT_NAME}.pfx" -out "${CERT_NAME}.tmp.key" -passin:"${CERT_NAME}" -nocerts 
openssl rsa -in "${CERT_NAME}.tmp.key" -out "${CERT_NAME}.key" -passin:"${CERT_NAME}" 