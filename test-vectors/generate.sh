echo "\n🌱 building test vector generators..."

docker-compose build --remove-orphans

echo "\n🌱 dilithium-pqcrypto..."

IMPLEMENTATION=dilithium-pqcrypto
INPUT=/data/dilithium-pqcrypto/input.json
OUTPUT=/data/dilithium-pqcrypto/output.json

docker-compose run $IMPLEMENTATION \
dilithium-pqcrypto generate \
--input $INPUT \
--output $OUTPUT

