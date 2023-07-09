%%%
title = "JOSE and COSE Encoding for SPHINCS+"
abbrev = "jose-cose-sphincs-plus"
ipr= "trust200902"
area = "Internet"
workgroup = "COSE"
submissiontype = "IETF"
keyword = ["JOSE","COSE","PQC","SPHINCS+"]

[seriesInfo]
name = "Internet-Draft"
value = "draft-ietf-cose-sphincs-plus-latest"
stream = "IETF"
status = "standard"

[pi]
toc = "yes"

[[author]]
initials = "M."
surname = "Prorock"
fullname = "Michael Prorock"
organization = "mesur.io"
  [author.address]
  email = "mprorock@mesur.io"

[[author]]
initials = "O."
surname = "Steele"
fullname = "Orie Steele"
organization = "Transmute"
  [author.address]
  email = "orie@transmute.industries"

[[author]]
initials = "R."
surname = "Misoczki"
fullname = "Rafael Misoczki"
organization = "Google"
  [author.address]
  email = "rafaelmisoczki@google.com"

[[author]]
initials = "M"
surname = "Osborne"
fullname = "Michael Osborne"
organization = "IBM"
  [author.address]
  email = "osb@zurich.ibm.com"

[[author]]
initials = "C"
surname = "Cloostermans"
fullname = "Christine Cloostermans"
organization = "NXP"
  [author.address]
  email = "christine.cloostermans@nxp.com"

%%%

.# Abstract

This document describes JSON and CBOR serializations for SPHINCS+,
a Post-Quantum Cryptography (PQC) signature suite.

This document does not define any new cryptography, only seralizations
of existing cryptographic systems.

This document registers key types for JOSE and COSE, specifically `HASH`.

Key types in this document are specified by the cryptographic algorithm
family in use by a particular algorithm as discussed in RFC7517.

This document registers signature algorithms types for JOSE and COSE,
specifically `SPHINCS+256s` and others as required for use of various
parameterizations of the SPHINCS+ post-quantum signature scheme.

Note to RFC Editor:
SPHINCS+ is described and noted as a part of the
[2022 PQC Selected Digital Signature Algorithims](https://csrc.nist.gov/Projects/post-quantum-cryptography/selected-algorithms-2022)
As a result, this document should not be proceed to AUTH48 until NIST
completes paramter tuning and selection as a part of the
[PQC](https://csrc.nist.gov/projects/post-quantum-cryptography) 
standardization process.

{mainmatter}

# Notational Conventions

The key words "**MUST**", "**MUST NOT**", "**REQUIRED**", "**SHALL**", "**SHALL NOT**", "**SHOULD**",
"**SHOULD NOT**", "**RECOMMENDED**", "**MAY**", and "**OPTIONAL**" in this
document are to be interpreted as described in [@!RFC2119].

# Terminology

The following terminology is used throughout this document:

PK : The public key for the signature scheme.

SK : The secret key for the signature scheme.

signature : The digital signature output.

message : The input to be signed by the signature scheme.

sha256 : The SHA-256 hash function defined in [@RFC6234].

shake256 : The SHAKE256 hash function defined in [@!RFC8702].

# SPHINCS-PLUS

This section defines core operations used by the signature scheme, as
proposed in [@!SPHINCS-PLUS].

## Overview

This section of the document describes the hash-based signature scheme
SPHINCS+. The scheme is based on the concept of authenticating a large
number or few-time signatures keypair using a combination of Merkle-tree
signatures, a so-called hypertree. For each message to be signed a
(pseudo-)random FTS keypair is selected with which the message can be
signed. Combining this signature along with an authentication path
through the hyper-tree consisting of hash-based many-time signatures
then gives the SPHINC+ signature. The parameter set is strategically
chosen such that the probability of signing too many messages with a
specific FTS keypair to impact security is small enough to prevent
forgery attacks. A trade-off in parameter set can be made on security
guarantees, performance and signature size.

SPHINCS+ is a post-quantum approach to digital signatures that is
promises Post-Quantum Existential Unforgeability under Chosen Message
Attack (PQ-EU-CMA), while ensuring that the security levels reached meet
security needs for resistance to both classical and quantum attacks. The
algoritm itself is based on the hardness assumptions of its underlying
hash functions, which can be chosen from the set Haraka, SHA-256 or
SHAKE256. For all security levels the only operations required are calls
to these hash functions on various combinations of parameters and
internal states.

Contrary to CRYSTALS-Dilithium and Falcon, SPHINCS+ is not based on any
algebraic structure. This reduces the possible attack surface of the
algorithm.

SPHINCS+ brings several advantages over other approaches to signature
suites:

- Post-quantum in nature - use of cryptographically secure hash
  functions and other approaches that should remain hard problems even
  when under an attack utilizing quantum approaches
- Minimal security assumptions - compared to other schemes does not base
  its security on a new paradigm. The security is solely based on the
  security of the assumptions of the underlying hash function.
- Performance and Optimization - based on combining a great many hash
  function calls of SHA-256, SHAKE256 or Haraka means existing (secure)
  SW and HW implementations of those hash functions can be re-used for
  increased performance
- Private and Public Key Size - compared to other post-quantum
  approaches a very small key size is the form of hash inputs-outputs.
  This then has the drawback that either a large signature or low
  signing speed has to be accepted
- Cryptanalysis assuarance - attacks (both pre-quantum and quantum) are
  easy to relate to existing attacks on hash functions. This allows for
  precise quantification of the security levels
- Overlap with stateful hash-based algorithms - means there are
  possibilities to combine implementions with those of XMSS and LMS. For
  example, both have the same underlying hash functions and utilize
  existing HW acceleration. Furthermore, an API to a XMSS implementation
  can be directly used by the subroutines of Sphincs+
- Inherent resistance against side-channel attacks - since its core
  primitive is a hash function, it thereby is hard to attack with
  side-channels.

The primary known disadvantage to SPHINCS+ is the size signatures, or
the speed of signing, depending on the chosen parameter set. Especially
in IoT applications this might pose a problem. Additionally hash-based
schemes are also vulnerable to differential and fault attacks.

## Core Operations

Core operations used by the signature scheme should be implemented
according to the details in [@!SPHINCS-PLUS]. Core operations include
key generation, sign, and verify.

## Using SPHINCS-PLUS with JOSE

This sections is based on [CBOR Object Signing and Encryption (COSE) and
JSON Object Signing and Encryption
(JOSE)](https://datatracker.ietf.org/doc/html/rfc8812#section-3)

### SPHINCS-PLUS Key Representations

A new key type (kty) value "HASH" (for keys related to the family of
algorithms that utilize hash based approaches to post-quantum
cryptography) is defined for public key algorithms that use base 64
encoded strings of the underlying binary material as private and public
keys and that support cryptographic sponge functions. It has the
following parameters:

- The parameter "kty" MUST be "HASH".

- The parameter "alg" MUST be specified, and its value MUST be one of
  the values specified the below table

| alg         | Description                          |
| ----------- | ------------------------------------ |
| SPHINCS+128s | SPHINCS+ with parameter set of 128s |
| SPHINCS+128f | SPHINCS+ with parameter set of 128f |
| SPHINCS+192s | SPHINCS+ with parameter set of 192s |
| SPHINCS+192f | SPHINCS+ with parameter set of 192f |
| SPHINCS+256s | SPHINCS+ with parameter set of 256s |
| SPHINCS+256f | SPHINCS+ with parameter set of 256f |

- The parameter "pset" MAY be specfied to indicate the paramter set in
  use for the algorithm, but SHOULD also reflect the targeted NIST level
  for the algorithm in combination with the specified paramter set. For
  "alg" "HAS" one of the described parameter sets as listed in the
  section SPHINCS+ Algorithms MUST be specified.

- The parameter "x" MUST be present and contain the public key encoded
  using the base64url [@!RFC4648] encoding.

- The parameter "d" MUST be present for private keys and contain the
  private key encoded using the base64url encoding. This parameter MUST
  NOT be present for public keys.

When calculating JWK Thumbprints [@!RFC7638], the four public key fields
are included in the hash input in lexicographic order: "kty", "alg", and
"x".

When using a JWK for this algorithm, the following checks are made:

- The "kty" field MUST be present, and it MUST be "HASH" for JOSE.

- The "alg" field MUST be present, and it MUST represent the algorith
  and parameter set.

- If the "key_ops" field is present, it MUST include "sign" when
  creating a HASH signature.

- If the "key_ops" field is present, it MUST include "verify" when
  verifying a HASH signature.

- If the JWK "use" field is present, its value MUST be "sig".

### SPHINCS-PLUS Algorithms

In order to reduce the complexity of the key representation and
signature representations we register a unique algorithm name per pset.
This allows us to omit registering the `pset` term, and reduced the
likelyhood that it will be misused. These `alg` values are used in both
key representations and signatures.

Sphincs+ targets different security levels (128-, 192- and 256-bit
security) and tradeoffs between size and speed. For each security level
a small (s) and fast (f) parameter set is provided.

| kty         | alg           | Paramter Set |
| ----------- | ------------- | ------------ |
| HASH        | SPHINCS+128s  | 128s         |
| HASH        | SPHINCS+128f  | 128f         |
| HASH        | SPHINCS+192s  | 192s         |
| HASH        | SPHINCS+192f  | 192f         |
| HASH        | SPHINCS+256s  | 256s         |
| HASH        | SPHINCS+256f  | 256f         |

## Using SPHINCS-PLUS with COSE

The approach taken here matches the work done to support secp256k1 in
JOSE and COSE in [@!RFC8812].

The following tables map terms between JOSE and COSE for signatures.

| Name            | Value | Description                      | Recommended |
| --------------- | ----- | -------------------------------- | ----------- |
| SPHINCS+128s    | TBD   | SPHINCS+ with parameter set 128s | No          |
| SPHINCS+128f    | TBD   | SPHINCS+ with parameter set 128f | No          |
| SPHINCS+192s    | TBD   | SPHINCS+ with parameter set 192s | No          |
| SPHINCS+192f    | TBD   | SPHINCS+ with parameter set 192f | No          |
| SPHINCS+256s    | TBD   | SPHINCS+ with parameter set 256s | No          |
| SPHINCS+256f    | TBD   | SPHINCS+ with parameter set 256f | No          |

The following tables map terms between JOSE and COSE for key types.

| Name       | Value | Description                          | Recommended |
| ---------- | ----- | ------------------------------------ | ----------- |
| HASH       | TBD   | kty for hash based digital signature | No          |

# Security Considerations

The following considerations SHOULD apply to all parmeter sets described
in this specification, unless otherwise noted.

Care should be taken to ensure "kty" and intended use match, the
algorithms described in this document share many properties with other
cryptographic approaches from related families that are used for
purposes other than digital signatures.

## Validating public keys

All algorithms in that operate on public keys require first validating
those keys. For the sign, verify and proof schemes, the use of
KeyValidate is REQUIRED.

## Side channel attacks

Implementations of the signing algorithm SHOULD protect the secret key
from side-channel attacks. Multiple best practices exist to protect
against side-channel attacks. Any implementation of the the Sphincs+
signing algorithms SHOULD utilize the following best practices at a
minimum:

- Constant timing - the implementation should ensure that constant time
  is utilized in operations
- Sequence and memory access persistance - the implemention SHOULD
  execute the exact same sequence of instructions (at a machine level)
  with the exact same memory access independent of which polynomial is
  being operated on.
- Uniform sampling - care should be given in implementations to preserve
  the property of uniform sampling in implementation and to prevent
  information leakage.

## Randomness considerations

It is recommended that the all nonces are from a trusted source of
randomness.

# IANA Considerations

The following has NOT YET been added to the "JSON Web Key Types"
registry:

- Name: "HASH"
- Description: Hash based post-quantum signature algorithm key pairs
- JOSE Implementation Requirements: Optional
- Change Controller: IESG
- Specification Document(s): Section 3.1 of this document (TBD)

The following has NOT YET been added to the "JSON Web Key Parameters"
registry:

- Parameter Name: "pset"
- Parameter Description: The parameter set of the crypto system
- Parameter Information Class: Public
- Used with "kty" Value(s): "HASH"
- Change Controller: IESG
- Specification Document(s): Section 2 of this document (TBD)

The following has NOT YET been added to the "JSON Web Key Parameters"
registry:

- Parameter Name: "d"
- Parameter Description: The private key
- Parameter Information Class: Private
- Used with "kty" Value(s): "HASH"
- Change Controller: IESG
- Specification Document(s): Section 2 of RFC 8037

The following has NOT YET been added to the "JSON Web Key Parameters"
registry:

- Parameter Name: "x"
- Parameter Description: The public key
- Parameter Information Class: Public
- Used with "kty" Value(s): "HASH"
- Change Controller: IESG
- Specification Document(s): Section 2 of RFC 8037

The following has NOT YET been added to the "JSON Web Signature and
Encryption Algorithms" registry:

- Algorithm Name: "SPHINCS+128s"
- Algorithm Description: SPHINCS+128s signature algorithms
- Algorithm Usage Location(s): "alg"
- JOSE Implementation Requirements: Optional
- Change Controller: IESG
- Specification Document(s): Section 5.1 of this document (TBD)
- Algorithm Analysis Documents(s): (TBD)

The following has NOT YET been added to the "JSON Web Signature and
Encryption Algorithms" registry:

- Algorithm Name: "SPHINCS+128f"
- Algorithm Description: SPHINCS+128f signature algorithms
- Algorithm Usage Location(s): "alg"
- JOSE Implementation Requirements: Optional
- Change Controller: IESG
- Specification Document(s): Section 5.1 of this document (TBD)
- Algorithm Analysis Documents(s): (TBD)

The following has NOT YET been added to the "JSON Web Signature and
Encryption Algorithms" registry:

- Algorithm Name: "SPHINCS+192s"
- Algorithm Description: SPHINCS+192s signature algorithms
- Algorithm Usage Location(s): "alg"
- JOSE Implementation Requirements: Optional
- Change Controller: IESG
- Specification Document(s): Section 5.1 of this document (TBD)
- Algorithm Analysis Documents(s): (TBD)

The following has NOT YET been added to the "JSON Web Signature and
Encryption Algorithms" registry:

- Algorithm Name: "SPHINCS+192f"
- Algorithm Description: SPHINCS+192f signature algorithms
- Algorithm Usage Location(s): "alg"
- JOSE Implementation Requirements: Optional
- Change Controller: IESG
- Specification Document(s): Section 5.1 of this document (TBD)
- Algorithm Analysis Documents(s): (TBD)

The following has NOT YET been added to the "JSON Web Signature and
Encryption Algorithms" registry:

- Algorithm Name: "SPHINCS+256s"
- Algorithm Description: SPHINCS+256s signature algorithms
- Algorithm Usage Location(s): "alg"
- JOSE Implementation Requirements: Optional
- Change Controller: IESG
- Specification Document(s): Section 5.1 of this document (TBD)
- Algorithm Analysis Documents(s): (TBD)

The following has NOT YET been added to the "JSON Web Signature and
Encryption Algorithms" registry:

- Algorithm Name: "SPHINCS+256f"
- Algorithm Description: SPHINCS+256f signature algorithms
- Algorithm Usage Location(s): "alg"
- JOSE Implementation Requirements: Optional
- Change Controller: IESG
- Specification Document(s): Section 5.1 of this document (TBD)
- Algorithm Analysis Documents(s): (TBD)

# Appendix

## General References

- JSON Web Signature (JWS) - [RFC7515][spec-jws]
- JSON Web Encryption (JWE) - [RFC7516][spec-jwe]
- JSON Web Key (JWK) - [RFC7517][spec-jwk]
- JSON Web Algorithms (JWA) - [RFC7518][spec-jwa]
- JSON Web Token (JWT) - [RFC7519][spec-jwt]
- JSON Web Key Thumbprint - [RFC7638][spec-thumbprint]
- JWS Unencoded Payload Option - [RFC7797][spec-b64]
- CFRG Elliptic Curve ECDH and Signatures - [RFC8037][spec-okp]
- SPHINCS+ - [SPHINCS-PLUS][spec-sphincs-plus]

[RFC2119]: https://tools.ietf.org/html/rfc2119
[spec-b64]: https://tools.ietf.org/html/rfc7797
[spec-cookbook]: https://tools.ietf.org/html/rfc7520
[spec-jwa]: https://tools.ietf.org/html/rfc7518
[spec-jwe]: https://tools.ietf.org/html/rfc7516
[spec-jwk]: https://tools.ietf.org/html/rfc7517
[spec-jws]: https://tools.ietf.org/html/rfc7515
[spec-jwt]: https://tools.ietf.org/html/rfc7519
[spec-okp]: https://tools.ietf.org/html/rfc8037
[spec-secp256k1]: https://tools.ietf.org/html/rfc8812
[spec-thumbprint]: https://tools.ietf.org/html/rfc7638
[spec-sphincs-plus]:
    https://sphincs.org/data/sphincs+-round3-specification.pdf

<reference anchor='SPHINCS-PLUS' target='https://sphincs.org'> <front>
    <title>Sphincs+ Stateless Hash-based Signatures</title> <author
        initials='A.' surname='Hulsing' fullname='Andreas Hulsing'>
        <organization>Eindhoven University of Technology
         (NL)</organization> </author> <date year='2017'/> </front>
        </reference>

## Appendix A.  Acknowledgements

We would like to especially thank David Balenson for careful
review of approaches taken in this document. We would also
like to thank Michael B. Jones for guidance in authoring.

## Appendix B.  Document History

-01

* Added Acknowledgements
* Added Document History
* Updated test vectors

-00

* Created draft-ietf-cose-sphincs-plus-00 from
  draft-ietf-cose-post-quantum-signatures-01 following working group
  feedback

## Appendix C.  Test Vectors

### HASH SPHINCS+256s

#### publicKeyJwk
```json
========== NOTE: '\' line wrapping per RFC 8792 ==========
{
  "kty": "HASH",
  "alg": "SPHINCS+256s",
  "x": "TUhJd0NBWUdLODRQQmdRUkEyWUFBQUFBUVFRY0FTMHM3TldiWHFIZVRCY0NN\
K0xkdytzN0FwZjBxRzEzM1pLQVdNTEx4dExldlhhM2NncE51K3dNcnlxQll1TW9yZW5Z\
OHhIRURjbWJreGFpNEppbHNPZ1dwQTdQcTM5Q3hHeWFuazltT29ySU5PUzJpWkRvdWky\
cm45VktrWms9",
  "use": "sig"
}
```

#### privateKeyJwk
```json
========== NOTE: '\' line wrapping per RFC 8792 ==========
{
  "kty": "HASH",
  "alg": "SPHINCS+256s",
  "x": "TUhJd0NBWUdLODRQQmdRUkEyWUFBQUFBUVFRY0FTMHM3TldiWHFIZVRCY0NN\
K0xkdytzN0FwZjBxRzEzM1pLQVdNTEx4dExldlhhM2NncE51K3dNcnlxQll1TW9yZW5Z\
OHhIRURjbWJreGFpNEppbHNPZ1dwQTdQcTM5Q3hHeWFuazltT29ySU5PUzJpWkRvdWky\
cm45VktrWms9",
  "d": "TUlId0FnRUFNQWdHQml2T0R3WUVFUVNCNEFTQjNRQUFBSGt3ZHdJQkFRUWdv\
TkErdTdVbSt6dy80ZlkvRFhhY3J5VjRTWG85WlVNUjgwVm9XdnBCOVcyZ0NnWUlLb1pJ\
emowREFRZWhSQU5DQUFRY0FTMHM3TldiWHFIZVRCY0NNK0xkdytzN0FwZjBxRzEzM1pL\
QVdNTEx4dExldlhhM2NncE51K3dNcnlxQll1TW9yZW5ZOHhIRURjbWJreGFpNEppbEtz\
Rnh6SWowVi9kTUo2bHFhNENEeGRwMjVzVlJmSWpPbHNHaU5uQitFb0N3NkJha0RzK3Jm\
MExFYkpxZVQyWTZpc2cwNUxhSmtPaTZMYXVmMVVxUm1iRG9GcVFPejZ0L1FzUnNtcDVQ\
WmpxS3lEVGt0b21RNkxvdHE1L1ZTcEda",
  "use": "sig"
}
```

#### jws
```jws
========== NOTE: '\' line wrapping per RFC 8792 ==========
eyJhbGciOiAiU1BISU5DUysyNTZzIiwgImt0eSI6ICJIQVNIIiwgInR5cCI6ICJKV1Qi\
fQ.eyJtZXNzYWdlIjogImhlbGxvIHdvcmxkIn0.AAAARzBFAiEA1CQSv8SrGS4c6LFPl\
gi3Xf7t-Q8Yf7918anK6aG78nkCIFuno_ijVT-1T3-fxitjESUzJlhrWMmUthshR-3LG\
RSkYqmVjMYkWKct67p6TPTTbc2F-bj5_zlmAHRBCjlRraErhmKoIQbxmyugrq5YUViwy\
PUrvluHzud7kWM5CdEUfo25TES9aj4pBTazIHeq3PtwFEWJWgLl33DcdrEqaEGoZko5X\
ONPKCjvt32E0B8bvZMBi-u54ifMG3Bk8N4DPK4fpH4It4pZ11G2VbJQu1raLvMjvrvgg\
b0ioO9LhiCKqp4zxDNUd251M3Cj8aNHrmySsULkzw2vVRRzOWfbe3dchh8ujdL-qAVoi\
77YzHg_ojqlkmNmOvRotVy8JW1dHdBgnsYNAvQKWkug7H2nMKFkDxu-oOtryxzMVxBcl\
vyfW0lhSvn6dQiFkgdSUrvktMMoUwFTQpdM9EwrjHfFIpVTd7w3cQsVw8D3UQwxPNUes\
1BZZ9wuHnERaK5SCVRCPrH9gTTl9yi0OZOVa3OE_ZzG_gJxsIN_rwcUyEhRmAlLau9Zi\
0sUzSaLlUrH9HSYuzIzGCc-Qe76tEix9mTNQR0_r83W20XfO-oiHGliPn3quisK818vn\
d4khX7F2iq8o6xDQ-0YxFOAJeugfIEiwvr4_WlwOosMi00eCiWl8f9Z_pk1XMVtdmX_a\
_mV5BxXu7hadToCx5B53L5Zzq24z68D5jHRpuyoL-vZon6yDa40GVr_hznqkjMURcgcz\
kiWBIWGMrZaxeioGx28OW6mW55RgRQXoBMbkFTvIaZrzyC6_UFcAfRIQE4M6p7A0uQnf\
dG3oP0Xmumomtf1Mp6ueUi9WQbl3K9c0lvalkyfEbOItPzYWivJ7vQq8tunWIRgBV7tJ\
9bRPC-4S4QeFzEMpzq_DMkn2FdjkC2pfVydPAicsKa8iW76JIRGM7V7DpkF0-s2Y_Xhw\
SF8JV3zReuIs3Me3NMWkhmVz-5fyU-FFxxUDmDl8YXrh2CJ_NnX6KPsGJEpL7RJ7AlS7\
88SCBQYl_OtXo5PMZDGgfZgiYUSBqZWl6WP7AAhFVtlGPEryrp7NKfMnzq8EZEvMZYJV\
RXfL3m934wHrYM5itGA_2S3DPrmWqxMY3dEqFyVBkNURndzoqxPxXR0e9KPyGsnietA2\
SzsBC5ApUPuSPzgMkoJ1jh9cE9jW-3SznXSz-OLu1Gq_9MgOxw-MLxq3Wid1NgvdttnM\
JlQPm2apFi3UUi5dyDOIzZSCo2gbAr0-vQIQOmyKZyCJTz6sdLqkv3L1JPGcssXQn5eK\
pAsOv8T4GXJmNEdL_0WoNzaSVJIFfoZLKcEU0X9wqVKz9sohAT0kZgtBgjGOyhsn2VWD\
mjTOgDvscB1VxHH7EI8ViEfNEdUhFrDE29tEA7JWPJ3ET80xUffFGrFZt2RgHDzd1p_s\
umnK6RF3C44yo3xs31yl00sttOqh8UI4KN4xEcux_s48GM4DZDMTkTqvfy4pDCSmJ8lT\
zp0Vey6g_rqCJd8soTgZiKf469DGmmWA8ivQ3Dz8Va8Pd-AHEPNkOmlpJPgexCzxsJjN\
BNc5n-3JTfRH9v91Lq2ewAEuW36Ri5ukGcIix045bt71icS_TBE002HrCFO5jhSEupmp\
sgMQw4uqmk2fXAiFA-zLd7A_0HBzhMcyZt6x3uAcuCwLl9fsn-vBXxViIrNW93kjl8dL\
CyDFZuU2znZ13Mo_PTalHaDT9VL9Lg1P1_MNQT2CZf3Qc-e9A-U95L5NjOXX1EtU6qQ4\
k865DJpvCkcluA1iHMac9Mot1Xw_NEgZviFdO8J0K_PXDI8vH47dpTKOTa4ywbEjOQCC\
fni4l4kom9nUPwYif1EZcNsM9rsBObKVIyy_mtq5w-p0v1A3EvoqtsVuQI4ckagmgZm9\
_zzLyxQsFAKUZdc14LLE8B_z0kGwflmRwbVSZxsYpLCfZ1qM51X2WK_pixnAnLOMEGde\
ObAWCNOgJyr67waK0GdpitVOA1ti4EDs8sCDA-9sV6ajzwCweqdOzAvJkiEdOyFglKgj\
L6CQyYmzpkZrh5-CmL54yzCd7FbaRFED1mJEmJFC8M4TWa91b0GoAJ9JeftQUC-2DgZr\
4xlTTka0Ol00HqEsp7NuMbBSmtYCDl60XIFiacB3EHu9ke12Xa19amc-h4LsNxAM8Igf\
NiOwmULv1upZMO-XrMyc8Dit5z5_t16iYZUhrJOvQ-Q49cpe32RS7V8PI_g7okvYqJmZ\
Ooreh7l-iMcIVSnAnXCWSuFT5US_3ZlC7nElRntr46b2GYDLvQuAE2XJIPkR2SCK0oii\
Nh3fpQ4F2F81md1mB07MNEa0yqDap7VMSMk4fTlzeN_rpuwhtrx8t2QX9ce1clC5ihjF\
jm6c7Rd7mSjoUlpSGeajzlKn5BIsI1xtM5GAmfHXiYPOENGONXQglQNeZ0Jf0hNJ4u88\
kfs4_H2ypUevsXUcfQ_mgt4B8G19zu-iDc9ayFdS2fG1FI04_FS8wZ-K8iWSdX3rxo4I\
1mcbF-bI165UsGDWcbEH1YTWfez1HdFwkvfYnX2Y_h3ZX126eYu6ZgbzhhqGZjhqFq8k\
VQZ2i4uvVmzm0GNW4Isb4IDW2fcQILf_RTI8n6z_JdXX-UdGswUyGUGs6BrQ-amIQuqh\
Bwrixc3l3REKEl5Hve1FX2uSvQfHgiu6t-bIaICwjuDcYvOLHWLaxB_1UUoDNPKqMAuz\
sPn6GDHn_PUnTVxg8fprvd93JWa1Doh2DzjQmvKy9bMt4D_X93b7T1_W7N9iIWCXC7qN\
FUcEdMZmOFgKQVrF0aeMWhRyDX4Xj53qtcC2Nujbn3xWyA8RmrubpT9ml3D36C6sCiFt\
EqHQotbCTHXKEci3MUQ2DJf1R690s1Omou4DxvYCVsUuVIRHPP2joa8UuQ8vDg3dxXwz\
lO_jbLx4PP__OjiUsGzOtV0YkXwWS2LahNlTaiyp1DFmzC5ZoGa-KVSVhW2cQinT3PDq\
96m-bTgzrPrY6WV9TW4J6WzRiJDlYwujo1ctGmgMBYZyZcucAZr6o9iioLnxlePxmNlf\
cLFOKgLc7Zi9ZF-2bbgTm6kGDaes2r7WS6X2UgMYgDTSVlMSfLa34uMwxs2x1P_0qjGi\
DBj7Ps_zNggZqrHcZwg3-Brp6jHMMhcS6cABEj2B5pZatyO2zl3qjX-_Ke7gTgS00eo_\
0VLzt_uYdczsqXOfl2x_ystRJidUBn7z3PmUkPPb13fXp7Lf2cKhPE8Wf86ZzRqAy3fh\
AywG5qpojtW4ezfWPYv8geO2eguMsK7FYFJ8uBERitiAkniQsxCwcS7MKaT8iRqhYHIR\
OIl_UsdhP3lrMCPOnMk30q_tq_o8HG3f-wZOZujYqIgqV1yol4h0PxMVI_SbWsT48XhX\
yS6BRPOBkdydyNumDrik2F5G2it5vEsD8Sq3_COrTAtjvp2oHubm45jWsTsQIitAe6s4\
BfWr401qd89UOJmJnqKErlQprps3oJiXBSzTF_TwVdeDM4veqBuQw4il6HS3iW2OdvmS\
hsum4tK-IDw9Jk3gNcROf1MakV5e1fZBDxN2lTY7qrk7e9JvYRdW0NHnLZrsgXD6nR9e\
o3q_iku1fb_R992nV5VNe_8x9jG7v9R9x-2HL2pPxNifurHF8a8BA69Yqu5AjrKjJJaG\
S98P4qlsUn1FD-XpjFGrwFSqJfYVz_rbcBhdLRcM3xDavd1M1oD7TTfaaiSy_U_OhO5u\
leN0Gt7wIHNjHg2pwwfYbKw_oP4MN9N7yH13joNpqZzb_8TuZstoT99vAJqySO3FMAgb\
FYixoRDgMOJUE9fEbefHtBTaFccpDLgco6fn7QDL-xSFkTpYLGkxAXD4-HtjmfblFAHl\
Byijlar3ZFo770ywAznGI0miJlDBzXQ-oDJo8M-dAg2N1vjryeXQsLvqjsAE--NLxIIp\
lZVkGolHCgxl2ppeXt-QcA5hnxcRzFcajGp5seycyuDx6k6O-2YKURa2rvlSFNSvAYr1\
C6K_3JLijI3qdD5Df3U7pmz-VXzDTqbku47lneX3Re7P_Z_Ano3TKAHK0kOHgYwEb4jm\
Ha7GDnHbDVmUU5tqsylxScrRTNWWxn-T_R7VvlGDhyQdHlcRGtHsVSN94s9QWQu5eNAy\
GMAHJKzYgqWfZcrVk6xnsi5aDBpt-lT_R-9pwa8yQpjOEYopEDLenaeQBOsZzXVOTDpm\
7J0TUEMURHlISBllcVh31YmHdvuUc_wQ0iibPf_nqRS6Xj5jvmPj-xbeRZsjSSKYEOzx\
BKGiMdUNVCnO93Rjoh17f-XtjpXv76eA_KJOafvnWsmwIID1hJggXHhFMy79JqxrEKLh\
bMVBLTG53Euhwkv-RopOxaMfLOW79z-OpPqY-pzaMzXijM0xELmSjTP1984045J2vS59\
whEmVDeGy8Ipseba-Vs2SCZ5rb_ZMXoFPZwJf_CZ0BuGDdwMWZ72QSq5G4t_kiJLxWN-\
L47Iedzr9NsK7358IRVBkheOBoTxc8P0iQo5mGj0LowWppOu6AHkJC4s9TLK-_MFmV8-\
JwJhF2oVYmZo3moCosR_8v5NphYWmHBWrTm9Q64CWugyhzdWjoQmaJjW_L-sEj8VBRmt\
IaTZdFwsJLgcdE1bGYtA-waRvYj_4oy_lPLdOIADrT-4Em1ZAd2WrOBHt359oMYN0qKC\
ljdK8iTDvl_EfgsknnF8ilvZhhaFCbeLVkJAORHDkTO4Wgsqqr80TQWo0gD2dR2Tdndv\
NZ-zF-q1qsyr6qA_3bEBUBEY7cxHgf-Q4kcz4sjGrCTNwYCuds75Ce4wQFveBPSzAxmM\
0pKD4QYz_EO6HX1BzLXs_qLc2Pq-kvyllyA4IsAAktSEGFmTj3lZ9SHeh1xkaZ2kr4vO\
grGo4EyQpeQuCMNaUHBEOBCYHaefBmOMIdZHsSFQLZxizMwoqi_j1EfV7igLtq00A58d\
M9C1EKC39_hGHRQX1GvMRN70IFOh4sIpSWSCZoXUfsFfShPIdki_oFgTQH_32OkBvjOM\
VQ5H09yX9y1r7sDfkWRx714ZtkECbZfha05-aN3NS37wizuLgFLOexXWM704IXoX9hGr\
EBDHjO2zfuEupGuhldi3R4-zU94uY-7K50R_FFx-uGjqOC6xrxTV8EaO_yDgoHQSR1xz\
hHnbdR5-WOGzbL1_MqHDMphnydJHfTZtvWqHj3FaIqeKpczrNGqSYXaPZVyIoitpXrWQ\
Uie9IWIM8jCqhkxaZhz0fG8GZqUso-ZpjTrGNv61OLTTNzNwVtKLxgxUuLworzWkdwAp\
-pWI82FITmhiC9LkgZTr8aPkqi7dk_ZP3hnfk9Iokjktey5u9zKvp0ZObsU5m9IRGFxA\
fM7pxsbzDpLQ7TCmL6rhc-bbKcw_dLEZRxJynPeFtpqSKfi2OLDGUgJdcMI9HSjMZRWU\
eAM0we0wcBCD9HWobNMC4miLG7MVPEt9958BD_-8yKKsuo9sD0Sqq9Xud0WPXxvKBfF-\
ntnAA7TXjcu0mT9MNXOV3YaWLTuTVGs7aPjYJUzSoqJzTEty4aHKhc1YybgqWogIidNm\
VgWB2eF7IbZFujvcxJNb3_RTmrBKOpG0aaEaiv-0CA13-LWXkLtK06381mOHaigcyxcz\
rhmGsw3VSdr_Qvozb4R95C7vhiOKGRAMTRqtY-ZVZvIZ-DFTGvVMKSybp8CXqIMcsd9f\
gELbTVZXI4gB48IG9WWXuulsTm5YLsbhAC_lxH2FSVD9G0C_mCR2FcdhU1P6gPRgDMy9\
bosIc38Fd-gMYUQHPBht3feWUhY2llMklMGN6FUKP8xJy_gLoQM6u4GxhSBuzFlxfZjJ\
skfx8UrJAanxXNutxGL0TX8cYlz0EWVZXkQ1CreYHpVQnne6Jhe6CSTkQUvvTVol9sAA\
v9dO7Egq7NNm73xJhsqNsoMl5Un-yeiK_3Q172OhvIeAxFfy4K5B8w8KzbssVTm92c-9\
kKFDRSQ8RqHALLt1hSYwdr09oIVIgdipY-_VFBJYMkanzFwGlyDOO6awkIgyGJcB1TAK\
-k3XbKgMrADxPaq0607q_CKlYSqw8cxoF5aDdaM1wnS7QgsctGEhPMzjIAU10rPm0XnO\
JS2Pq0QpjyJQURvR3x6FXTIeVujqMeZ4H5RSitXCNjQJjq00C0In54q-Tp7YWBu6erSl\
ebe5Mp75xM3ZyKjceT6Nz-C8N4QxsXlPpvga6OlQ0mNmZS2vHcl1fKZ4hi_FTBkEDfF6\
ij5rW3iYoIAX96uw-icNEx8OGnkaN6tag59wRgOgDljILudcG3Rcavmm6nmzSWAkFpKI\
T9EB4b7sLPnA7tnNuyn6CMEs8lLgehsNWym7WDZW1npOfg-wAnNCOLjKuS5ekydzahhK\
quRAH8eUM3ankCE6ug02LCfQDj4i8MPqeTi7EBRLNIswizUZiZ_VrJYq7HRJhVmkyaBb\
XVTVcvsLyib9FyxW7TqtAZN4M4ZvzC7tPjnE08tbbUX2oaZWJjN_qorX74XGuJlcSGgu\
JoaC-3wFxWjfzFSO7WY3Ajne_ybkF925SxHS5UMDeiC6Mdod99NT-wpDm28wQwCb0rLJ\
Dnv6b-n_2Y5z_B3DkuRDwHhAwg9YYrbbpcgfQHDHqNe7K1cbMhOpfVLV2oLdRtdgKcIH\
M8VIctsoTBJ_uAKYDqQeu3uKZMxH8W9bs84G3WciYXncHmadX4ddgbuOc0iM3ZpHjiyP\
tmPPzORBJvcg3LeQLjK1lxv8VcI6n7uNVGQXu_QjmYddhCKHvsx07HwvdJ_bdH4L8T9E\
y4-4qjlKt9uz-oNyiefrM0mq7_rBis-kb0EJO7UhFBkRo5v2zp68_PjqYDPzlUaLYgmw\
oIvN1jWNkM_mNShB4o_-v6iPh2xuxGGWkCi0oDb3HPQJgL6CNpv5sipkQW6T3jKi5Wrx\
uBV0GmrZweBFYGhFFaO3d_gsIT_1jOEE4puTbcevep9rSofxgW9S7sBw9B-3KYsBHLP7\
ya5ve8k_DehEhxZcbP2aNxMjhoDFzplmKeI6krASpoX8BfWyO-oWE8j7roxrGmmb9NzX\
Y_8yWANPr9fxtbhJFRMg1UHNn8-YlQQAw6LubUff_2tY2oHxT6h-N6GMwnLD9sQZviAL\
iFMuBoPMnFFcEPRnLhiteb8agasxamvAKoqWcZcnDtUqh4daj-PpljTV6z1NdYw6qC8c\
1r2cm7ZM2KfRtobefQwB28GpGG2EJmT__FrkbfiWIEVnf75KIAr88YVT7Z8NhpCts0Q8\
6z9i6c8QsgSehI2fDhvc5OLCecLTaUJ4NKWafsagDbvzx0nQ_sEI0Egqu8p2rMiFA_ai\
uDMyaUv3FIsoiXINltDi7XraTnUiuEuHILmWUMV-dNnddzpRkzJk0y64vytJ_YkDkmXa\
sea8evBIMqWj20ULN9P7SQpHUgX-TyXZiB-Gw4q1HRTxjyhJaiADNYeo-shVSh_R99J0\
Kazr2PzU-TncKTw4jzStjocHWfqKBj4uIkqaZjiO5ISSoUxcKUdCdOIx8W3VfL0MdeO0\
RJ7HCCBKDpkoQOjgPW0SIzpPWrLlr0S93BmgeukA_jmoxBWeCa1GY8qZQ_0I2uh2Ii2e\
GirRwZ3Pc8yH-3wQOHVGlWhXz-9V8asCe3hp35OGWCWpWh5zMJXQYi0W9dTT5GtH8pSM\
crEd4FFSMG9FJJlL2sLB8D6ayYIubSd-uJPJdXjkkb8MoIeFV8y8YsR1b9P6NURWHMBX\
8I2tsoj026yyWeAx-sGkKjPt-0EtNsdZPnQuCm3seq4ifpbXJhrlLkdoLj6F88XOwk3e\
Gp9CZhAKCWNUSczuyXsu-m7qCS876TZUE3YNa4spQG-dZBuK4spWd6Lz12mfSgtlucw2\
YMRPbQAcYHqDIjehZeMOo7q8XTK3rzy4UfH7a3fLbO6QnFfL2Hr0mqIXuhqWOpM2humg\
wxvkcpzED57VAKfWQvBQzuwXJ6ErlfUR2Bo7uLtv14IdS5F6ZELKtKbCdjFEL2TrONId\
Er0g4Vu60J1P4lDKCnETxSRM6UF8PolT9AVz-duahQrlf8G8_fM6yUOfJuGK8M9tT5Ro\
R1iou9LhZsAYIaWd-pZlIllsyyoP7BuEi_1Rm3QWMwRWn_0iawf9BuAasNqItgKHarJ2\
l6NcbcyRcQKr_9RlThDbHyegb1RlsMnHOn-Ipo8HgGSCxZNIanjUBQe0-VoUo9hnZY4X\
eZHGYp-mrb62A_YWuKwq0l_xnvyguzq8tu_wn7KYiQwnk7QEm1uD03zpDmCdgpaL1Nld\
hQ4_fmgYEceoLhXIp58tAcAxNDhvJ5eZ9O7Oz0OJzgMBoZkoGTxMhMw1ZXx49rMeLW1b\
W0SIrkGMf89LUqm65ITgxDEfzcoTYPe8WqjrNBrp4cyLLqoDvZqTmFB5qNzhl_Y-GIUe\
jZv9Y0OgWKnBzlRH55Htgq4gtWdlUYZSIU3ZnjQlFaSL3vYA1h4vMj5uTWGcDbQW5sKS\
f6UalUni3BIhF_44p8PyNP1JwFnR-z8zzJL-CttG1QDd9FNbin7qnPV8j1aC04Mct04e\
bEYQ1Sa3xgLMQghqbINv4ECi0B84j4gCYyqgIEjNnfm3kipUpTsWR-uYsWQ75SunibEy\
c80fH5xjIa9DV3a5LgsKTadl2K8cA3DRQcYDV59lBJCx2ds7MhviGsQwyLfWYR3YaVwi\
6DiDRy4Q6OxVaJ8-Srn53f9w-g5lWpNRKhz-TNJAzPTGJdbz9y8O9qLEDYFyznOwy-1c\
q8eK_7zJmqdUnfVxkjdy2rLRq74dyF2bv-BZgmm637VTf3Rh8KtyU9EpMzxXe3ZYQ2hI\
VNdxnpozFJW5XDKFTs31rNgt11fJ_XxAyYbvwzQhmFxyQP4z7tbKbnxPD7Qid6Sq9J4c\
NFhVy2zjDiqFdMcybBRlloJ01raJWiDTH1g_At0moVQGtKmdnjUj8GOjjx3-YSfZy8NY\
XeHhR2HG5JU0CDuuLjPquPj3q4yVzDZlhN0eUX-IjYaLJnI2-mioHA7B2xB-zkXU1zcU\
KsFtxG6Ho9-_IDgt8d3NMFRaGgSm5ScLaJuaBpZ4dagIUa0Ep6oZ9l4SG_UHiwkuxJ6P\
dYJJmKqhnLM6ufVCIonA8Km0lZn_LaT-roMOFuOJD2E1opMfPSndJANHpRP7hAKS33hv\
zR6mH8tE4TjfJx0PCHT-e5daUpxm8FxOsxdTQ2QlaXg-j6qNX4NFpHbNuTqI1s7lx4lK\
Z-walQibC4REg9mHXEsNdsfPdPOHa2qM7s25-XI14s3x5NDxaMWdP7BIVUgpDKjxQ8kl\
yVC919wbylZjuN_x59lVGa1bjWBskHi9LZcfRf0WjQXHKUIfXIxZ6nz14W6wjgJkV1lz\
DnCxLibDbmUR3GoFTElLvQKf5J54Hvb_VBMHyb5xAe6kE-jBzkM7wIcLISU0xmW1FyXo\
q2NtYeLsy0ovCQWMw3FCaRfrp3Hi1eGdLB6mTGw-wXSt4r1BhfBssENaX3Ogo6PCVi5u\
rXzYvKXS0yhX9vBXzGmfi40_w93RSEBmaZuawv9yVrC6EXyj4FEKfQppWf_yvGBMn-AP\
OffCMSUpiKr2ljqOk-DwNgtINjdzN5RfsUjCSud2nFuPkvbEGTFcftOaUCaKr4D_7Huy\
V-ttEeyMPDI7u0X3n8DRU39C8XybGT_FMw7xCtGp73DCxurd1QIOosug2omjyguBmTNv\
WRqxqZWIEXpxGNp4FKDIdmpBnYcfS4pRg0dVYxBK789-PR26XhPuJ8Kqmb2gNo26cuox\
i1t1Go8vWRFnZZYMiRrujgcMfz06UkMl6EiTJHdJxI4NLZMnlEnGXsnBAUz4I7DnAa7G\
xktfPGB5qNpg4ysdlPzn6XBh64tLDRv6ANrwauzTK-RJKlqu6dxjjRj5RM0rYwQPIuXx\
ru_9RW3JfZ2fQ1EYTPa-RXctBGTq60qZV9aqjRZSnzIUJPh9N-ts3V9-mfh_XX0L0JIB\
19kVdNb-P3tdsMjyV2FqRSbxCbbc2qJbFv6kVlI7MfHu5x-bxgVF2VsYZo0CgkzpRmw4\
4MBd_I3plRXLsEXQnViv2BUgzoTjmmtf6L5usG75IHl8zE31qpn5-Qs3Q5gwNG4Fdr-n\
dIDFNO6L7U68R6D4xeFvAjcaS7vxjgaLRRXwNdZBm5tVfj8-G82nO8ZOr_KxW4Cuc1z_\
dS0bXIfdNhKUzTYwz8Xo4-7gzkdgoZgzFmhy89fcoKVCIWgdzuk6XoqmMuw7LGSYi6S-\
T1a-JPLCSxGQ4cNbnUriGM0-9TKh1Jqyzv6F1Ik2bgxdSPq86CEWUq6AT7JOoG5faJdW\
wxoIuCFgTV3VkXf5Y06A8YAbblUUTwywrKUF5KnziWlhWX88tXAeUfPO8z-k4T3cPnpZ\
aVj2gcSG5NE4_DNnVIeDJM0H9cDkM4ope27OgfyN2fhxXvdjfiu1mYBooqZmGiAa9pVH\
Fektuon7wYFKjBXwfzLErqFpvm5v0m1_intaOmpx8JHaOnJEP4UgXHVe-iHOZdU3QOhC\
qyXlsY
```



{backmatter}
