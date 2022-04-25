const fs = require("fs");
const dilithium = require("@transmute/dilithium-key-pair");

const loadJsonFile = (absolutePath) => {
  return JSON.parse(fs.readFileSync(absolutePath).toString());
};

const generate = async ({ input, output, format }) => {
  const inputJson = loadJsonFile(input)
  const k = await dilithium.DilithiumKeyPair.generate();
  const jwk = k.privateKeyJwk;
  const jws = 'jwk does not use base64url - https://github.com/transmute-industries/dilithium-key-pair/issues/1'
  const verified = false
  const outputJson = { input: inputJson, output: { jwk, jws, verified } };
  fs.writeFileSync(output, JSON.stringify(outputJson, null, 2));
};
  
module.exports = {
  generate
};