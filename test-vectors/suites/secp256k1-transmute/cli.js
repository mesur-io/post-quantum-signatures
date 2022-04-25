const fs = require("fs");
const lib = require('@transmute/did-key.js');
const jose = require('jose');

const loadJsonFile = (absolutePath) => {
  return JSON.parse(fs.readFileSync(absolutePath).toString());
};

const generate = async ({ input, output, format }) => {
  const inputJson = loadJsonFile(input)
  const {keys} = await lib.secp256k1.generate({secureRandom: ()=>{
    return Buffer.from(
      inputJson.seed,
      'hex'
    );
  }});
  const { privateKeyJwk } = keys[0]
  const jwk = {
    "kty": privateKeyJwk.kty,
    "crv": privateKeyJwk.crv,
    "alg": "ES256K",
    "x": privateKeyJwk.x,
    "y": privateKeyJwk.y,
    "d": privateKeyJwk.d
  }
  const message = inputJson.seed;
  const jws = await new jose.CompactSign(
    new TextEncoder().encode(
      message
    )
  )
    .setProtectedHeader({ alg: jwk.alg })
    .sign(await jose.importJWK(jwk))
  const { payload, protectedHeader } = await jose.compactVerify(jws, await jose.importJWK(jwk))
  const verified = new TextDecoder().decode(payload) === message && protectedHeader.alg === jwk.alg;
  const outputJson = { input: inputJson, output: { jwk, jws, verified } };
  fs.writeFileSync(output, JSON.stringify(outputJson, null, 2));
};
  
module.exports = {
  generate,
};