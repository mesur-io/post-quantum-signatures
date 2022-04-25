const yargs = require("yargs");
const cli = require("./cli");
yargs.scriptName("✨");

const suite = 'secp256k1';
yargs.command(
  `${suite} [action]`,
  "Post Quantum Signature Test Vector Generator",
  {
    input: {
      alias: "i",
      description: "Path to input document",
      demandOption: true,
    },
    output: {
      alias: "o",
      description: "Path to output document",
      demandOption: true,
    },
    format: {
      alias: "f",
      description: "format (JOSE / COSE)",
      default: "jose",
    },
  },
  async (argv) => {
    if (cli[argv.action]){
        await cli[argv.action]({
            input: argv.input,
            output: argv.output,
            format: argv.format,
        });
    }
  }
);

yargs.help().alias("help", "h").demandCommand().argv;