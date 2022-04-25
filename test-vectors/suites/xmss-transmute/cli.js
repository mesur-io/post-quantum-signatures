const fs = require("fs");
const xmss = require('@transmute/xmss');
const base64url = require('base64url');

const loadJsonFile = (absolutePath) => {
  return JSON.parse(fs.readFileSync(absolutePath).toString());
};

const generate = async ({ input, output, format }) => {
  const inputJson = loadJsonFile(input);
  const k = await xmss.generate();
  const jwk = {
    kty: k.kty, 
    alg: k.alg, 
    x: k.x, 
    d:k.d
  }
  const m = base64url.encode(JSON.stringify({alg: jwk.alg})) + '.' + base64url.encode(inputJson.seed)
  const message = Uint8Array.from(Buffer.from(m))
  const s = await xmss.sign(message, jwk)
  const jws = m + '.' + s
  const verified = await xmss.verify(message, s, jwk)
  const outputJson = {input: inputJson, output: {jwk, jws, verified}};
  fs.writeFileSync(output, JSON.stringify(outputJson, null, 2));
};
  

const sign = async ({ input, output, format }) => {
  const outputJson = {input: loadJsonFile(input)};
  fs.writeFileSync(output, JSON.stringify(outputJson, null, 2));
};


const verify = async ({ input, output, format }) => {
  const outputJson = {input: loadJsonFile(input)};
  fs.writeFileSync(output, JSON.stringify(outputJson, null, 2));
};

module.exports = {
  generate,
  sign, 
  verify
};