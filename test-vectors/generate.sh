echo "\n🌱 building test vector generators..."

docker-compose build --remove-orphans

echo "\n🌱 dilithium-pqcrypto-go..."

IMPLEMENTATION=dilithium-pqcrypto-go
EXECUTABLE=/dilithium
INPUT=/data/dilithium-pqcrypto/input.json
OUTPUT=/data/dilithium-pqcrypto/output.json

docker-compose run $IMPLEMENTATION \
$EXECUTABLE \
generate \
--input $INPUT \
--output $OUTPUT