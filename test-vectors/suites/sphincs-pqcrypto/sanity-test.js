

const jwk  = require('./jwk')
const jws  = require('./jws')
const message = `It’s a dangerous business, Frodo, going out your door.`;
const msg = new TextEncoder().encode(message);


// (async ()=>{
//   console.log('key conversions')
//   const { publicKey,  privateKey} = await jwk.generate()
//   const exported1 = jwk.exportPublicKeyJwk({ publicKey })
//   const imported1 = jwk.importJwk(exported1)
//   const exported2 = jwk.exportPublicKeyJwk({ publicKey: imported1 })
//   console.log(JSON.stringify(exported1) === JSON.stringify(exported2))

//   const exported3 = jwk.exportPrivateKeyJwk({ publicKey, privateKey })
//   const imported2 = jwk.importJwk(exported3)
//   const exported5 = jwk.exportPrivateKeyJwk({ publicKey: imported1, privateKey: imported2  })
//   console.log(JSON.stringify(exported3) === JSON.stringify(exported5))

//   console.log({ publicKeyJwk: exported1, privateKeyJwk: exported5 })
// })()

// (async ()=>{
//   console.log('sign and verify raw')
//   const {  publicKey,  privateKey } = await jwk.generate()
//   const sig1 = await jws.signRaw(msg, privateKey)
//   const ver1 = await jws.verifyRaw(sig1, publicKey)
//   const decoded = new TextDecoder().decode(ver1)
//   console.log(decoded === message)
// })()



(async ()=>{
  console.log('JWS - sign and verify ...')
  const { publicKey,  privateKey} = await jwk.generate()
  const { publicKeyJwk, privateKeyJwk } = await jwk.exportKeyPairJwk({ publicKey,  privateKey})
  const jws1 = await jws.sign({
    header: { 'kid': '123'}, 
    payload: {
      message
    }, 
    privateKeyJwk,
  })
  const { protectedHeader, payload } = await jws.verify({
    jws: jws1,
    publicKeyJwk
  })
  // console.log({protectedHeader, payload})
  console.log(protectedHeader.alg === publicKeyJwk.alg)
  console.log(payload.toString() === JSON.stringify({message}))
})()