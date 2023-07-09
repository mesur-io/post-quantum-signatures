const fs = require("fs");

const jwk = require('./jwk');
const jws = require('./jws');

const loadJsonFile = (absolutePath) => {
  return JSON.parse(fs.readFileSync(absolutePath).toString());
};

const generate = async ({ input, output, format }) => {
  const inputJson = loadJsonFile(input)
  const { publicKey, privateKey } = await jwk.generate();
  const { publicKeyJwk, privateKeyJwk } = jwk.exportKeyPairJwk({ publicKey, privateKey })
  const header = {}
  const message = inputJson.seed;
  const jws1 = await jws.sign({ header, payload: message, privateKeyJwk })  
  const {protectedHeader, payload } = await jws.verify({ jws: jws1, publicKeyJwk })
  const verified = new TextDecoder().decode(payload) === message && protectedHeader.alg === publicKeyJwk.alg;
  const outputJson = { input: inputJson, output: { publicKeyJwk, privateKeyJwk, jws: jws1, verified } };
  fs.writeFileSync(output, JSON.stringify(outputJson, null, 2));
};
  
module.exports = {
  generate,
};