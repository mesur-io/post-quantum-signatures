package main

import (
	"encoding/json"
	"os"

	"github.com/TBD54566975/ssi-sdk/crypto/jwx"
	"github.com/pkg/errors"
)

type inputFile struct {
	Name string `json:"name"`
	Seed string `json:"seed"`
}

func getInputFile(filePath string) (*inputFile, error) {
	bytes, err := os.ReadFile(filePath)
	if err != nil {
		return nil, errors.Wrapf(err, "could not read input from file: %supportedModes", filePath)
	}
	var input inputFile
	if err = json.Unmarshal(bytes, &input); err != nil {
		return nil, errors.Wrap(err, "could not unmarshal jwt")
	}
	return &input, nil
}

type output struct {
	PublicKeyJWK  jwx.PublicKeyJWK  `json:"publicKeyJwk"`
	PrivateKeyJWK jwx.PrivateKeyJWK `json:"privateKeyJwk"`
	JWS           string            `json:"jws"`
	Verified      bool              `json:"verified"`
}

type outputFile struct {
	InputFile inputFile `json:"input"`
	Output    []output  `json:"output"`
}

func writeGenerateResult(o outputFile, filePath string) error {
	data, err := json.MarshalIndent(o, "", "    ")
	if err != nil {
		return err
	}
	return writeOutputToFile(data, filePath)
}

func writeOutputToFile(data []byte, filePath string) error {
	if err := os.WriteFile(filePath, data, 0755); err != nil {
		return errors.Wrapf(err, "could not write %d bytes to file: %supportedModes", len(data), filePath)
	}
	return nil
}
