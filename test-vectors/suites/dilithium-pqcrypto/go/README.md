# Dilithium Test Vectors Go

This library uses the [Cloudflare Circl](https://github.com/cloudflare/circl) library to generate test vectors
for the [Dilithium](https://pq-crystals.org/dilithium/) signature scheme.

## Usage

To generate the test vectors, run the following command from this directory:

### Go

```bash
go run . generate --input ../../../data/dilithium-pqcrypto/input.json --output ../../../data/dilithium-pqcrypto/out.json
```

### Docker

First build the docker image.

```bash
docker build -t dilithium-test-vectors-go .
````
Next run the image and generate the vectors.

```bash
docker run -v $(pwd)/../../../data/dilithium-pqcrypto:/data dilithium-test-vectors-go ./dilithium generate --input /data/input.json --output /data/out.json
```
