#!/bin/bash

# Exit on any error
set -e

# Script directory
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

echo "🧹 Cleaning up existing certificates..."
rm -f "$DIR"/*.pem

echo "📜 Generating SSL certificates for local development..."

# Change to certificates directory
cd "$DIR"

# Generate RSA private key instead of ED25519
echo "🔑 Generating RSA private key..."
openssl genrsa -out key.pem 4096

# Generate CSR using our config
echo "📝 Generating certificate signing request..."
openssl req -new -key key.pem -out csr.pem -config local.conf

# Generate self-signed certificate
echo "🔒 Generating self-signed certificate..."
openssl x509 -req \
    -in csr.pem \
    -signkey key.pem \
    -out cert.pem \
    -days 365 \
    -sha256 \
    -extensions v3_req \
    -extfile local.conf

echo "✅ SSL certificates generated successfully!"

# Clean up CSR as it's no longer needed
rm csr.pem

# Set appropriate permissions
chmod 600 key.pem
chmod 644 cert.pem