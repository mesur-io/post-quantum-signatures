#!/bin/bash

# Check the number of arguments
if [ "$#" -ne 2 ]; then
  echo "Usage: verify_jws.sh [OPENSSL_ALG] [jwk.json]"
  exit 1
fi

OPENSSL_ALG=$1
jwk_file=$2

# Function to perform Base64URL decoding
base64url_decode() {
  local input=$1

  local length=$((${#input} % 4))
  if [ $length -eq 2 ]; then
    input="$input=="
  elif [ $length -eq 3 ]; then
    input="$input="
  fi

  echo -n "$input" | sed 's/-/+/g; s/_/\//g' | openssl enc -A -base64 -d
}

# Function to perform just the URL decoding
url_decode() {
  local input=$1

  local length=$((${#input} % 4))
  if [ $length -eq 2 ]; then
    input="$input=="
  elif [ $length -eq 3 ]; then
    input="$input="
  fi

  echo -n "$input" | sed 's/-/+/g; s/_/\//g'
}

# Read the JWS from stdin
jws=$(cat)

# Split the JWS into its components
IFS='.' read -ra components <<< "$jws"
header_base64url=${components[0]}
payload_base64url=${components[1]}
signature_base64url=${components[2]}

# Decode the header and extract the algorithm (alg) and key type (kty)
#header=$(base64url_decode "$header_base64url")
#alg=$(echo "$header" | jq -r '.alg')
#kty=$(echo "$header" | jq -r '.kty')

# Read the JWK file
jwk=$(cat "$jwk_file")

# Extract the public key from JWK
public_key=$(echo "$jwk" | jq -r '.x')
#private_key=$(echo "$jwk" | jq -r '.d')

# Create a temporary file to store the public key
public_key_file=$(mktemp --suffix .pem)

# Generate the public key in PEM format
echo -e "-----BEGIN PUBLIC KEY-----\n\
$(base64url_decode "$public_key" | fold -w 64)\n\
-----END PUBLIC KEY-----" > "$public_key_file"

# Verify the signature
signing_input=$(echo -n "$header_base64url.$payload_base64url" )
signature_base64=$(url_decode "$signature_base64url" )

# Create a temporary file for the binary signature
signature_file=$(mktemp)
echo -n "$signature_base64" | base64 -d > $signature_file

verification_result=$(echo -n "$signing_input" | openssl dgst -signature $signature_file -verify $public_key_file)

# Check the verification result
if [ "$verification_result" == "Signature Verified Successfully" ] || [ "$verification_result" == "Verified OK" ]; then
  echo "Verification successful."
else
  echo "Verification failed."
fi

# Remove the temporary file
rm "$public_key_file" "$signature_file"
