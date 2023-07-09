#!/bin/bash

# Check the number of arguments
if [ "$#" -ne 5 ]; then
  echo "Usage: generate_jwk.sh [OPENSSL_ALG] [kty] [alg] [private_key.pem] [public_key.pem]"
  exit 1
fi

OPENSSL_ALG=$1
kty=$2
alg=$3
private_key_file=$4
public_key_file=$5

# Function to remove the delimiters from PEM files
remove_delimiters() {
  sed -e '1d;$d' "$1" | tr -d '\n'
}

# Function to perform Base64URL encoding
base64url_encode() {
  local input=$1

  echo -n "$input" | base64 -w 0 | tr '+/' '-_' | tr -d '='
}

# Generate the private key
openssl genpkey -algorithm "$OPENSSL_ALG" > "$private_key_file"

# Generate the public key
openssl pkey -pubout -in "$private_key_file" > "$public_key_file"

# Read the private key file and encode it
private_key=$(remove_delimiters "$private_key_file")
private_key_base64url=$(base64url_encode "$private_key")

# Read the public key file and remove the delimiters
public_key=$(remove_delimiters "$public_key_file")
public_key_base64url=$(base64url_encode "$public_key")

# Generate the JWK
jwk='{
  "kty": "'"$kty"'",
  "alg": "'"$alg"'",
  "x": "'"$public_key_base64url"'",
  "d": "'"$private_key_base64url"'",
  "use": "sig"
}'

# Print the JWK
echo "$jwk"
