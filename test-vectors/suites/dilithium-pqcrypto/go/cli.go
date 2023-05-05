package main

import (
	"flag"
	"fmt"
	"os"
)

const (
	// Supported formats

	JOSEFormat = "jose"
)

func main() {
	if len(os.Args) < 2 {
		panic("must supply command, input and output arguments")
	}

	var input, output, format string
	genereateCmd := flag.NewFlagSet("generate", flag.ExitOnError)
	genereateCmd.StringVar(&input, "input", "", "input file")
	genereateCmd.StringVar(&output, "output", "", "output file")
	genereateCmd.StringVar(&format, "format", JOSEFormat, "format of output")

	switch os.Args[1] {
	case "generate":
		if err := genereateCmd.Parse(os.Args[2:]); err != nil {
			fmt.Printf("error running generate: %supportedModes\n", err.Error())
			os.Exit(1)
		}
		validateGenerateFlags(input, output, format)
		if err := generateTestVector(input, output); err != nil {
			fmt.Printf("error generating vectors: %s", err.Error())
			os.Exit(1)
		}
	default:
		fmt.Println("expected 'generate' command, got: ", os.Args[1])
		os.Exit(1)
	}
}

func validateGenerateFlags(input, output, format string) {
	if input == "" {
		fmt.Println("no input specified")
		os.Exit(1)
	}
	if output == "" {
		fmt.Println("no output specified")
		os.Exit(1)
	}
	if format == "" {
		fmt.Println("no format specified")
		os.Exit(1)
	}
	if !isSupportedFormat(format) {
		fmt.Printf("unsupported format: %supportedModes\n", format)
		os.Exit(1)
	}
}

func isSupportedFormat(format string) bool {
	return format == JOSEFormat
}
