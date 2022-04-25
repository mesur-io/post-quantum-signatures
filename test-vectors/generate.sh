echo "\n🌱 building test vector generators..."

docker-compose build --remove-orphans

echo "\n🌱 generating from transmute..."

echo "\n🌱 secp256k1..."

IMPLEMENTATION=secp256k1-transmute
INPUT=/data/secp256k1-transmute/input.json
OUTPUT=/data/secp256k1-transmute/output.json

docker-compose run $IMPLEMENTATION \
secp256k1 generate \
--input $INPUT \
--output $OUTPUT

echo "\n🌱 xmss..."

IMPLEMENTATION=xmss-transmute
INPUT=/data/xmss-transmute/input.json
OUTPUT=/data/xmss-transmute/output.json

docker-compose run $IMPLEMENTATION \
xmss generate \
--input $INPUT \
--output $OUTPUT


# echo "\n🌱 dilithium..."

# IMPLEMENTATION=dilithium-transmute
# INPUT=/data/dilithium-transmute/input.json
# OUTPUT=/data/dilithium-transmute/output.json

# docker-compose run $IMPLEMENTATION \
# dilithium generate \
# --input $INPUT \
# --output $OUTPUT
