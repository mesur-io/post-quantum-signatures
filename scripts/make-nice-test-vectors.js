
const fs = require('fs');
const path = require('path');

const loadVector = (outputFile)=>{
  return JSON.parse(fs.readFileSync(path.resolve(__dirname, outputFile)).toString())
}

const writeMarkdown = (outputFilePath, outputFileContent)=>{
  return fs.writeFileSync(path.resolve(__dirname, outputFilePath), outputFileContent)
}

const dilithium = loadVector('../test-vectors/data/dilithium-pqcrypto/output.json') ;
const falcon = loadVector('../test-vectors/data/falcon-pqcrypto/output.json') ;
const sphincs = loadVector('../test-vectors/data/sphincs-pqcrypto/output.json') ;

const suites = [dilithium, falcon, sphincs];




function testWhite(x) {
  var white = new RegExp(/^\s$/);
  return white.test(x.charAt(0));
};

// rfc8792
function wordWrap(str, maxWidth = 68) {
  var newLineStr = "\\\n"; done = false; res = '';
  while (str.length > maxWidth) {                 
      found = false;
      // Inserts new line at first whitespace of the line
      for (i = maxWidth - 1; i >= 0; i--) {
          if (testWhite(str.charAt(i))) {
              res = res + [str.slice(0, i), newLineStr].join('');
              str =  str.slice(i + 1);
              found = true;
              break;
          }
      }
      // Inserts new line at maxWidth position, the word is too long to wrap
      if (!found) {
          res += [str.slice(0, maxWidth), newLineStr].join('');
          str = "\\" + str.slice(maxWidth);
      }

  }

  return res + str;
}


(async ()=>{
  console.log('Add test vectors to latest spec...')

  let markdown = ''

  for (const suite of suites){
    const { publicKeyJwk, privateKeyJwk, jws } = suite.output
    console.log({publicKeyJwk, privateKeyJwk, jws})
    markdown += `### ${publicKeyJwk.kty} ${publicKeyJwk.alg}\n\n`
    markdown += "#### publicKeyJwk\n```json\n" + wordWrap(JSON.stringify(publicKeyJwk)) +"\n```\n\n"
    markdown += "#### privateKeyJwk\n```json\n" + wordWrap(JSON.stringify(privateKeyJwk)) +"\n```\n\n"
    markdown += "#### jws\n```jws\n" + wordWrap(jws) +"\n```\n\n"

    markdown += "\n"

  }

  writeMarkdown(`../test-vectors/data/markdown.md`, markdown)
})()