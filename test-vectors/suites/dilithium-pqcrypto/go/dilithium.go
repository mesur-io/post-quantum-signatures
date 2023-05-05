package main

import (
	"github.com/TBD54566975/ssi-sdk/crypto/jwx"
	"github.com/cloudflare/circl/sign/dilithium"
	"github.com/lestrrat-go/jwx/v2/jws"
	"github.com/pkg/errors"
)

// Registers the Dilithium Signers and Verifiers with the jwx library
func init() {
	jws.RegisterSigner(jwx.DilithiumMode2Alg, jws.SignerFactoryFn(jwx.NewDilithiumMode2Signer))
	jws.RegisterVerifier(jwx.DilithiumMode2Alg, jws.VerifierFactoryFn(jwx.NewDilithiumMode2Verifier))
	jws.RegisterSigner(jwx.DilithiumMode3Alg, jws.SignerFactoryFn(jwx.NewDilithiumMode3Signer))
	jws.RegisterVerifier(jwx.DilithiumMode3Alg, jws.VerifierFactoryFn(jwx.NewDilithiumMode3Verifier))
	jws.RegisterSigner(jwx.DilithiumMode5Alg, jws.SignerFactoryFn(jwx.NewDilithiumMode5Signer))
	jws.RegisterVerifier(jwx.DilithiumMode5Alg, jws.VerifierFactoryFn(jwx.NewDilithiumMode5Verifier))
}

const (
	keyID    = "#0"
	issuerID = "dilithium-test-vector"
)

func generateTestVector(inputFilePath, outputFilePath string) error {
	inFile, err := getInputFile(inputFilePath)
	if err != nil {
		return errors.Wrap(err, "could not get inputFile from input file")
	}
	outputs := make([]output, 0, len(supportedModes()))
	for _, m := range supportedModes() {
		pubKey, privKey, err := m.GenerateKey(nil)
		if err != nil {
			return errors.Wrap(err, "could not generate key")
		}
		pubKeyJWK, privKeyJWK, err := jwx.PrivateKeyToPrivateKeyJWK(keyID, privKey)
		if err != nil {
			return errors.Wrap(err, "could not convert private key to JWK")
		}

		// sign jws
		signer, err := jwx.NewJWXSigner(issuerID, keyID, privKey)
		if err != nil {
			return errors.Wrap(err, "could not create signer")
		}
		jws, err := signer.SignJWS([]byte(inFile.Seed))
		if err != nil {
			return errors.Wrap(err, "could not sign JWS")
		}

		// verify jws
		verifier, err := jwx.NewJWXVerifier(issuerID, keyID, pubKey)
		if err != nil {
			return errors.Wrap(err, "could not create verifier")
		}
		if err = verifier.VerifyJWS(string(jws)); err != nil {
			return errors.Wrap(err, "could not verify JWS")
		}
		outputs = append(outputs, output{
			PublicKeyJWK:  *pubKeyJWK,
			PrivateKeyJWK: *privKeyJWK,
			JWS:           string(jws),
			Verified:      true,
		})
	}
	o := outputFile{
		InputFile: *inFile,
		Output:    outputs,
	}
	if err = writeGenerateResult(o, outputFilePath); err != nil {
		return errors.Wrap(err, "could not write output to file")
	}
	return nil
}

// if you wish to generate vectors for specific modes remove the unnecessary modes here
func supportedModes() []dilithium.Mode {
	return []dilithium.Mode{dilithium.Mode2, dilithium.Mode3, dilithium.Mode5}
}
