#!/bin/bash

# Check the number of arguments
if [ "$#" -ne 2 ]; then
  echo "Usage: sign_jws.sh [OPENSSL_ALG] [jwk.json]"
  exit 1
fi

OPENSSL_ALG=$1
jwk_file=$2

# Function to perform Base64URL encoding
base64url_encode() {
  local input=$1

  echo -n "$input" | openssl enc -A -base64 | sed 's/+/-/g; s/\//_/g; s/=//g'
}
b64_base64url_encode() {
  local input=$1

  echo -n "$input" | sed 's/+/-/g; s/\//_/g; s/=//g'
}

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

# Read the JWK file
jwk=$(cat "$jwk_file")

# Extract the private key (d) from JWK and other info
private_key_b64url=$(echo "$jwk" | jq -r '.d')
kty=$(echo "$jwk" | jq -r '.kty')
alg=$(echo "$jwk" | jq -r '.alg')

# Convert the private key from Base64URL to Base64 format
private_key=$(base64url_decode "$private_key_b64url")

# Generate the header
header='{"alg": "'"$alg"'", "kty": "'"$kty"'", "typ": "JWT"}'
header_base64url=$(base64url_encode "$header")

# Create a temporary file to store the payload
payload_file=$(mktemp)

# Read the payload from stdin and save it to the temporary file
cat > "$payload_file"

# Create a temporary file to store the private key
private_key_file=$(mktemp --suffix .pem)

# Add the "-----BEGIN PRIVATE KEY-----" delimiter to the private key file
echo -n "-----BEGIN PRIVATE KEY-----"$'\n'"$private_key"$'\n'"-----END PRIVATE KEY-----" | fold -w 64 > "$private_key_file"

# Generate the payload Base64URL
payload_base64url=$(base64url_encode "$(cat "$payload_file")")

# Generate the signing input
signing_input="${header_base64url}.${payload_base64url}"

# Sign the message using the private key
signature_raw=$(echo -n "$signing_input" | openssl pkeyutl -sign -inkey "$private_key_file" -rawin | openssl enc -A -base64)
signature=$(b64_base64url_encode $signature_raw)

# Generate the JWS
jws="${header_base64url}.${payload_base64url}.${signature}"

# Print the JWS
echo "$jws"

# helpdul debugging print statements below:
# echo
# echo header: ${header_base64url}
# echo payload: ${payload_base64url}
# echo sig: ${signature}
# echo sig_raw: ${signature_raw}
# echo
# echo pem_file:
# cat ${private_key_file}
# echo

# Remove the temporary files
rm "$payload_file" "$private_key_file"

