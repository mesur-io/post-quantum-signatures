# JSON Encoding for Post Quantum Signatures

This is the working area for the individual Internet-Draft, "JSON Encoding for Post Quantum Signatures".

* [Editor's Copy](https://mesur-io.github.io/post-quantum-signatures/#go.draft-ietf-cose-post-quantum-signatures.html)
* [Datatracker Page](https://datatracker.ietf.org/doc/draft-ietf-cose-post-quantum-signatures)
* [Individual Draft](https://datatracker.ietf.org/doc/html/draft-prorock-cose-post-quantum-signatures)
* [Compare Editor's Copy to Individual Draft](https://mesur-io.github.io/post-quantum-signatures/#go.draft-post-quantum-signatures.diff)

A high level overview of our [goals with this draft is available](https://docs.google.com/presentation/d/1OZtW5v3lx8VBIFQ8P2A6IBZqJ3SYoxwrMlfqxVzfIBg/)


## Inclusion Criteria

In order to include a family, there must be a completed row in the following table.

If you see an incomplete row, and wish to contribute to check the open issues, and start opening PRs.

| family    | kty     | alg          | vectors     | spec                                                    |
|-----------|---------|--------------|-------------|---------------------------------------------------------|
| Dilithium | LWE     | CRYDI5       | in-progress | https://pq-crystals.org/dilithium/                      |
| Dilithium | LWE     | CRYDI3       | in-progress | https://pq-crystals.org/dilithium/                      |
| Dilithium | LWE     | CRYDI2       | in-progress | https://pq-crystals.org/dilithium/                      |
| Falcon    | NTRU    | FALCON1024   | in-progress | https://falcon-sign.info/                               |
| Falcon    | NTRU    | FALCON512    | in-progress | https://falcon-sign.info/                               |
| SPHINCS+  | HASH    | SPHINCS+128s | planned     | https://sphincs.org/                                    |
| SPHINCS+  | HASH    | SPHINCS+128f | planned     | https://sphincs.org/                                    |
| SPHINCS+  | HASH    | SPHINCS+192s | planned     | https://sphincs.org/                                    |
| SPHINCS+  | HASH    | SPHINCS+192f | planned     | https://sphincs.org/                                    |
| SPHINCS+  | HASH    | SPHINCS+256s | in-progress | https://sphincs.org/                                    |
| SPHINCS+  | HASH    | SPHINCS+256f | planned     | https://sphincs.org/                                    |

## Contributing

See the
[guidelines for contributions](https://github.com/mesur-io/post-quantum-signatures/blob/main/CONTRIBUTING.md).

Contributions can be made by creating pull requests.
The GitHub interface supports creating pull requests using the Edit (✏) button.

### Meetings and Collaboration

NB: Now that core drafting is complete these meetings have been discontinued until
further meetings are required

Participants to this work item are invited to a weekly meeting to discuss
[Pull Requests](https://github.com/mesur-io/post-quantum-signatures/pulls?q=is%3Apr+is%3Aopen+sort%3Aupdated-asc),
[Issues](https://github.com/mesur-io/post-quantum-signatures/issues?q=is%3Aissue+is%3Aopen+sort%3Aupdated-asc),
and [content on the spec](https://github.com/mesur-io/post-quantum-signatures/blob/main/draft-prorock-cose-post-quantum-signatures.md),
along with progress towards standardization.

Meetings are held weekly on Mondays at 10:00 ET / 15:00 GMT on Google Meet.
Video call link: [https://meet.google.com/bqb-omio-dtx](https://meet.google.com/bqb-omio-dtx)
Or dial: (US) +1 863-703-4902 PIN: 924 526 334#

More phone numbers are available for international callers [here](https://tel.meet/bqb-omio-dtx?pin=6212109710970)

## Key files and directories

Top level markdown files are the current editor versions.  At time of this writing there is one draft for each of 

- CRYSTALS Dilithium
- Falcon
- SPHINCS+

There is a corresponding folder for assets generated from each editor copy such as txt versions in RFC format
for submission to data tracker.

## Original Setup

Command line usage requires that you have the necessary software installed. Please review
[the detailed instructions](https://github.com/martinthomson/i-d-template/blob/main/doc/SETUP.md) or follow the quick-start instructions below.

The `Makefile` in this repository can be used to produce the following formatted `.txt` and `.html` versions of this draft for local review during development.

- draft-prorock-cose-post-quantum-signatures.html
- draft-prorock-cose-post-quantum-signatures.txt

_NOTE: With the exception of the recommended Docker build instructions, it is assumed that Python3 and `pip` are installed on the local system. Instructions for installing Python are out of scope for this guide, but can be found on the [main Python website](https://www.python.org/)._

### Build using Docker (Recommended)

The recommended method to produce formatted draft versions of the spec is to use Docker. This method does not require installation of build-specific software (other than Docker itself), and can be used on Mac OSX, Windows, and Linux.

_Example: build using docker_
```bash
docker run -it --rm -v `pwd`:`pwd` -w `pwd` martinthomson/i-d-template make
```

### Build on Ubuntu Linux

In order to build the project from the command-line on Ubuntu linux, you will need to ensure that you have all of the necessary supporting software installed.

_Example: install supporting software on Ubuntu Bionic_
```bash
sudo apt-get update -y
sudo apt-get install -y make
sudo python3 -m pip install xml2rfc
```

You will need to install a more recent version of `mmark` than is available in the ubuntu repositories. Visit the [github release page](https://github.com/mmarkdown/mmark/releases) for the `mmark` project and download/install the latest version.

_Example: manually install `mmark` v2.2.5_
```bash
wget https://github.com/mmarkdown/mmark/releases/download/v2.2.25/mmark_2.2.25_linux_amd64.tgz
tar xfz mmark_2.2.25_linux_amd64.tgz
mv mmark /usr/local/bin
```

Once all of the required software is in place, running `make` will produce the formatted output files for review.

_Example: produce output files using `make`:_
```bash
make
```

### Build on Mac OSX

In order to build the project from the command-line on OSX, you will need to ensure that you have all of the necessary supporting software installed.

_Example: install `make` and `mmark` using [Homebrew](https://brew.sh):_
```bash
brew install make mmark
```

The Python package [`xml2rfc`](https://pypi.org/project/xml2rfc/) is also required, and should be installed using `pip`.

_Example: install `xml2rfc` using `pip`_
```bash
pip install xml2rfc
```

Once all of the required software is in place, running `make` will produce the formatted output files for review.

_Example: produce output files using `make`:_
```bash
make
```

#### Related Work

- [pqc-for-engineers](https://github.com/paulehoffman/post-quantum-for-engineers/blob/main/pqc-for-engineers.md)
