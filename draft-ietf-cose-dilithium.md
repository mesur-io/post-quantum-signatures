%%%
title = "JOSE and COSE Encoding for Dilithium"
abbrev = "jose-cose-dilithium"
ipr= "trust200902"
area = "Internet"
workgroup = "COSE"
submissiontype = "IETF"
keyword = ["JOSE","COSE","PQC","DILITHIUM"]

[seriesInfo]
name = "Internet-Draft"
value = "draft-ietf-cose-dilithium-latest"
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

This document describes JSON and CBOR serializations for CRYSTALS
Dilithium, a Post-Quantum Cryptography (PQC) based suite.

This document does not define any new cryptography, only seralizations
of existing cryptographic systems.

This document registers key types for JOSE and COSE, specifically `MLWE`.

Key types in this document are specified by the cryptographic algorithm
family in use by a particular algorithm as discussed in RFC7517.

This document registers signature algorithms types for JOSE and COSE,
specifically `CRYDI3` and others as required for use of various
parameterizations of the post-quantum signature scheme CRYSTALS 
Dilithium.

CRYSTALS Dilithium is described and noted as a part of the
[2022 PQC Selected Digital Signature Algorithims](https://csrc.nist.gov/Projects/post-quantum-cryptography/selected-algorithms-2022)
As a result, this document should not be finalized until NIST completes paramter
tuning and selection as a part of the
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

# CRYSTALS-Dilithium

## Overview

This section of the document describes the lattice signature scheme
CRYSTALS-Dilithium (CRYDI). The scheme is based on "Fiat-Shamir with
Aborts"[Lyu09, Lyu12] utlizing a matrix of polynomials for key material,
and a vector of polynomials for signatures. The parameter set is
strategically chosen such that the signing algorithm is large enough to
maintain zero-knowledge properties but small enough to prevent forgery
of signatures. An example implementation and test vectors are provided.

CRYSTALS-Dilithium is a post-quantum approach to digital signatures that
is an algorithmic apprach that seeks to ensure key pair and signing
properties that is a strong implementation meeting Existential
Unforgeability under Chosen Message Attack (EUF-CMA) properties, while
ensuring that the security levels reached meet security needs for
resistance to both classical and quantum attacks. The algoritm itself is
based on hard problems over module lattices, specifically Ring Learning
with Errors (Ring-LWE). For all security levels the only operations
required are variants of Keccak and number theoretic transforms (NTT)
for the ring Zq[X]/(X256+1). This ensures that to increase or decrease
the security level involves only the change of parameters rather than
re-implementation of a related algorithm.

While based on Ring-LWE, CRYSTALS-Dilithium has less algebraic structure
than direct Ring-LWE implementations and more closely resembles the
unstructured lattices used in Learning with Errors (LWE). This brings a
theorectical protection against future algebraic attacks on Ring-LWE
that may be developed. Given the use of module lattices, this family of
approaches is often referred to as MLWE.

CRYSTALS-Dilithium, brings several advantages over other approaches to
signature suites:

- Post-quantum in nature - use of lattices and other approaches that
  should remain hard problems even when under attack utilizing quantum
  approaches
- Simple implementation while maintaining security - a danger in many
  possible approaches to cryptography is that it may be possible
  inadvertently introduce errors in code that lead to weakness or
  decreases in security level
- Signature and public key size - compared to other post-quantum
  approaches a reasonable key size has been achieved that also preserves
  desired security properties
- Conservative parameter space - parameterization is utilized for the
  purposes of defining the sizes of matrices in use, and thereby the
  number of polynomials described by the key material.
- Parameter set adjustment for greater security - increasing this matrix
  size increases the number of polynomials, and thereby the security
  level
- Performance and optimization - the approach makes use of well known
  transforms that can be highly optimized, especially with use of
  hardware optimizations without being so large that it cannot be
  deployed in embedded or IoT environments without some degree of
  optimization.

The primary known disadvantage to CRYSTALS-Dilithium is the size of keys
and signatures, especially as compared to classical approaches for
digital signing.

## Parameters

Unlike certain other approaches such as Ed25519 that have a large set of
parameters, CRYSTALS-Dilithium uses distinct numbers of paramters to
increase or decrease the security level according to the required level
for a particular scenario. Under CRYSTALS-Dilithium, the key parameter
specification determines the size of the matrix and thereby the number
of polynomials that describe the lattice. For use according to this
specification we do not recommend a parameter set of less than 3, which
should be sufficient to maintain 128 bits of security for all known
classical and quantum attacks. Under a parameter set at NIST level 3, a
6x5 matrix is utilized that thereby consists of 30 polynomials.

### Parameter sets

Parameter sets are identified by the corresponding NIST level per the
table below

{align="left"}

| NIST Level | Matrix Size | memory in bits |
| ---------- | ----------- | -------------- |
| 2          | 4x4         | 97.8           |
| 3          | 6x5         | 138.7          |
| 5          | 8x7         | 187.4          |

## Core Operations

Core operations used by the signature scheme should be implemented
according to the details in [@!CRYSTALS-Dilithium]. Core operations
include key generation, sign, and verify.

## Using CRYDI with JOSE

This sections is based on [CBOR Object Signing and Encryption (COSE) and
JSON Object Signing and Encryption
(JOSE)](https://datatracker.ietf.org/doc/html/rfc8812#section-3)

### CRYDI Key Representations

A new key type (kty) value "MLWE" is defined for public key algorithms that use
base 64 encoded strings of the underlying binary material as private and public
keys and that support cryptographic sponge functions. "MLWE" refers to for keys
related to the family of algorithms that utilize Learning With Errors approaches
to Post-quantum lattice module based cryptography It has the following
parameters:

- The parameter "kty" MUST be "MLWE".

- The parameter "alg" MUST be specified, and its value MUST be one of
  the values specified in the table below

| alg           | Description                          |
| ------------- | ------------------------------------ |
| CRYDI5        | CRYSTALS-Dilithium paramter set 5    |
| CRYDI3        | CRYSTALS-Dilithium paramter set 3    |
| CRYDI2        | CRYSTALS-Dilithium paramter set 2    |

- The parameter "pset" MAY be specfied to indicate the not only paramter
  set in use for the algorithm, but SHOULD also reflect the targeted
  NIST level for the algorithm in combination with the specified
  paramter set. For "alg" "CRYDI" one of the described parameter sets
  "2", "3", or "5" MUST be specified. Parameter set "3" or above SHOULD
  be used with "CRYDI" for any situation requiring at least 128bits of
  security against both quantum and classical attacks

- The parameter "x" MUST be present and contain the public key encoded
  using the base64url [@!RFC4648] encoding.

- The parameter "d" MUST be present for private keys and contain the
  private key encoded using the base64url encoding. This parameter MUST
  NOT be present for public keys.

Sizes of various key and signature material is as follows (for "pset"
value "2")

| Variable    | Paramter Name | Paramter Set | Size | base64url encoded size |
| ----------- | ------------- | ------------ | ---- | ---------------------- |
| Signature   | sig           | 2            | 3293 | 4393                   |
| Public Key  | x             | 2            | 1952 | 2605                   |
| Private Key | d             | 2            | 4000 | 5337                   |

When calculating JWK Thumbprints [@!RFC7638], the four public key fields
are included in the hash input in lexicographic order: "kty", "alg", and
"x".


### CRYDI Algorithms

In order to reduce the complexity of the key representation and
signature representations we register a unique algorithm name per pset.
This allows us to omit registering the `pset` term, and reduced the
likelyhood that it will be misused. These `alg` values are used in both
key representations and signatures.

| kty         | alg           | Paramter Set |
| ----------- | ------------- | ------------ |
| MLWE        | CRYDI5        | 5            |
| MLWE        | CRYDI3        | 3            |
| MLWE        | CRYDI2        | 2            |

#### Public Key

Per section 5.1 of [@!CRYSTALS-Dilithium]:

> The public key, containing p and t1, is stored as the concatenation of
> the bit-packed representations of p and t1 in this order. Therefore,
> it has a size of 32 + 288 kbytes.

The public key is represented as `x` and encoded using base64url
encoding as described in [@!RFC7517].

Example public key using only required fields:

```json
=============== NOTE: '\' line wrapping per RFC 8792 ================

{
  "kty": "MLWE",
  "alg": "CRYDI3",
  "x": "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\
/8uzsSQk0AbuhxWFQpSiBP8OZ/U="
}
```

Example public key including optional fields:

```json
=============== NOTE: '\' line wrapping per RFC 8792 ================

{
  "kid": "key-0",
  "kty": "MLWE",
  "alg": "CRYDI3",
  "key_ops": ["verify"],
  "x": "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\
/8uzsSQk0AbuhxWFQpSiBP8OZ/U="
}
```

#### Private Key

Per section 5.1 of [@!CRYSTALS-Dilithium]:

> The secret key contains p,K,tr,s1,s2 and t0 and is also stored as a
> bit-packed representation of these quantities in the given order.
> Consequently, a secret key requires 64 + 48 + 32((k+l) * dlog (2n+ 1)e
> + 14k) bytes. For the weak, medium and high security level this is
> equal to 112 + 576k+ 128l bytes. With the very high security
> parameters one needs 112 + 544k + 96l = 3856 bytes.

The private key is represented as `d` and encoded using base64url
encoding as described in [@!RFC7517].

Example private key using only required fields:

```json
=============== NOTE: '\' line wrapping per RFC 8792 ================

{
  "kty": "MLWE",
  "alg": "CRYDI3",
  "x": "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\
/8uzsSQk0AbuhxWFQpSiBP8OZ/U=",
  "d": "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\
owebEJAy63htMytq+xd3cJyZR0lWBUOqvSpd/A=="
}
```

Example private key using optional fields:

```json
=============== NOTE: '\' line wrapping per RFC 8792 ================

{
  "kid": "key-0",
  "kty": "MLWE",
  "alg": "CRYDI3",
  "key_ops": ["sign"],
  "x": "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\
/8uzsSQk0AbuhxWFQpSiBP8OZ/U=",
  "d": "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\
owebEJAy63htMytq+xd3cJyZR0lWBUOqvSpd/A=="
}
```

### CRYDI Signature Representation

For the purpose of using the CRYSTALS-Dilithium Signature Algorithm
(CRYDI) for signing data using "JSON Web Signature (JWS)" [@!RFC7515],
algorithm "CRYDI" is defined here, to be applied as the value of the
"alg" parameter.

The following key subtypes are defined here for use with CRYDI:

| "paramter" | CRYDI Paramter Set |
| ---------- | ------------------ |
| 5          | CRYDI5             |
| 3          | CRYDI3             |
| 2          | CRYDI2             |

The key type used with these keys is "MLWE" and the algorithm used for
signing is "CRYDI". These subtypes MUST NOT be used for key agreement.

The CRYDI variant used is determined by the subtype of the key (CRYDI3
for "pset 3" and CRYDI2 for "pset 2").

Implementations need to check that the key type is "MLWE" for JOSE and
that the pset of the key is a valid subtype when creating a signature.

The CRYDI digital signature is generated as follows:

1.  Generate a digital signature of the JWS Signing Input using CRYDI
    with the desired private key, as described in [Section
    3.2](#name-sign). The signature bit string is the concatenation of a
    bit packed representation of z and encodings of h and c in this
    order.

2.  The resulting octet sequence is the JWS Signature.

When using a JWK for this algorithm, the following checks are made:

- The "kty" field MUST be present, and it MUST be "MLWE" for JOSE.

- The "alg" field MUST be present, and it MUST represent the algorith
  and parameter set.

- If the "key_ops" field is present, it MUST include "sign" when
  creating an CRYDI signature.

- If the "key_ops" field is present, it MUST include "verify" when
  verifying an CRYDI signature.

- If the JWK "use" field is present, its value MUST be "sig".

Example signature using only required fields, represented in compact
form:

```json
eyJhbGciOiJQUzM4NCIsImtpZCI6ImJpbGJvLmJhZ2dpbnNAaG9iYml0b24uZX
hhbXBsZSJ9
.
SXTigJlzIGEgZGFuZ2Vyb3VzIGJ1c2luZXNzLCBGcm9kbywgZ29pbmcgb3V0IH
lvdXIgZG9vci4gWW91IHN0ZXAgb250byB0aGUgcm9hZCwgYW5kIGlmIHlvdSBk
b24ndCBrZWVwIHlvdXIgZmVldCwgdGhlcmXigJlzIG5vIGtub3dpbmcgd2hlcm
UgeW91IG1pZ2h0IGJlIHN3ZXB0IG9mZiB0by4
.
cu22eBqkYDKgIlTpzDXGvaFfz6WGoz7fUDcfT0kkOy42miAh2qyBzk1xEsnk2I
pN6-tPid6VrklHkqsGqDqHCdP6O8TTB5dDDItllVo6_1OLPpcbUrhiUSMxbbXU
vdvWXzg-UD8biiReQFlfz28zGWVsdiNAUf8ZnyPEgVFn442ZdNqiVJRmBqrYRX
e8P_ijQ7p8Vdz0TTrxUeT3lm8d9shnr2lfJT8ImUjvAA2Xez2Mlp8cBE5awDzT
0qI0n6uiP1aCN_2_jLAeQTlqRHtfa64QQSUmFAAjVKPbByi7xho0uTOcbH510a
6GYmJUAfmWjwZ6oD4ifKo8DYM-X72Eaw
```

The same example decoded for readability:

```json
=============== NOTE: '\\' line wrapping per RFC 8792 ===============

{
  "header": { "alg": "CRYDI3", "kid": "did:example:123#key-0" },
  "payload": "It's a dangerous business, Frodo, going out your door.\
\ You step onto the road, and if you don't keep your feet, there's\
\ no knowing where you might be swept off to.",
  "signature": "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"
}
```

## Using CRYDI with COSE

The approach taken here matches the work done to support secp256k1 in
JOSE and COSE in [@!RFC8812].

The following tables map terms between JOSE and COSE for signatures.

| Name   | Value | Description                             | Recommended |
| ------ | ----- | --------------------------------------- | ----------- |
| CRYDI5 | TBD   | CRYSTALS-Dilithium with parameter set 5 | No          |
| CRYDI3 | TBD   | CRYSTALS-Dilithium with parameter set 3 | No          |
| CRYDI2 | TBD   | CRYSTALS-Dilithium with parameter set 2 | No          |

The following tables map terms between JOSE and COSE for key types.

| Name   | Value | Description                                   | Recommended |
| ------ | ----- | --------------------------------------------- | ----------- |
| MLWE   | TBD   | kty for Learning with Errors based Signatures | No          |

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
against side-channel attacks. Any implementation of the the
CRYSTALS-Dilithium signing algorithms SHOULD utilize the following best 
practices at a minimum:

- Constant timing - the implementation should ensure that constant time
  is utilized in operations
- Sequence and memory access persistance - the implemention SHOULD
  execute the exact same sequence of instructions (at a machine level)
  with the exact same memory access independent of which polynomial is
  being operated on.
- Uniform sampling - uniform sampling is the default in
  CRYSTALS-Dilithium to prevent information leakage, however care should
  be given in implementations to preserve the property of uniform
  sampling in implementation.
- Secrecy of S1 - utmost care must be given to protection of S1 and to
  prevent information or power leakage. As is the case with most
  proposed lattice based approaches to date, fogery and other attacks
  may succeed, for example, with Dilithium through [leakage of
  S1](https://eprint.iacr.org/2018/821.pdf) through side channel
  mechanisms.

## Randomness considerations

It is recommended that the all nonces are from a trusted source of
randomness.

# IANA Considerations

The following has NOT YET been added to the "JSON Web Key Types"
registry:

- Name: "MLWE"
- Description: MLWE family post-quantum signature algorithm key pairs
- JOSE Implementation Requirements: Optional
- Change Controller: IESG
- Specification Document(s): Section 3.1 of this document (TBD)

The following has NOT YET been added to the "JSON Web Key Parameters"
registry:

- Parameter Name: "pset"
- Parameter Description: The parameter set of the crypto system
- Parameter Information Class: Public
- Used with "kty" Value(s): "MLWE"
- Change Controller: IESG
- Specification Document(s): Section 2 of this document (TBD)

The following has NOT YET been added to the "JSON Web Key Parameters"
registry:

- Parameter Name: "d"
- Parameter Description: The private key
- Parameter Information Class: Private
- Used with "kty" Value(s): "MLWE"
- Change Controller: IESG
- Specification Document(s): Section 2 of RFC 8037

The following has NOT YET been added to the "JSON Web Key Parameters"
registry:

- Parameter Name: "x"
- Parameter Description: The public key
- Parameter Information Class: Public
- Used with "kty" Value(s): "MLWE"
- Change Controller: IESG
- Specification Document(s): Section 2 of RFC 8037

The following has NOT YET been added to the "JSON Web Signature and
Encryption Algorithms" registry:

- Algorithm Name: "CRYDI2"
- Algorithm Description: CRYDI2 signature algorithms
- Algorithm Usage Location(s): "alg"
- JOSE Implementation Requirements: Optional
- Change Controller: IESG
- Specification Document(s): Section 3.1 of this document (TBD)
- Algorithm Analysis Documents(s): (TBD)

The following has NOT YET been added to the "JSON Web Signature and
Encryption Algorithms" registry:

- Algorithm Name: "CRYDI3"
- Algorithm Description: CRYDI3 signature algorithms
- Algorithm Usage Location(s): "alg"
- JOSE Implementation Requirements: Optional
- Change Controller: IESG
- Specification Document(s): Section 3.1 of this document (TBD)
- Algorithm Analysis Documents(s): (TBD)

The following has NOT YET been added to the "JSON Web Signature and
Encryption Algorithms" registry:

- Algorithm Name: "CRYDI5"
- Algorithm Description: CRYDI5 signature algorithms
- Algorithm Usage Location(s): "alg"
- JOSE Implementation Requirements: Optional
- Change Controller: IESG
- Specification Document(s): Section 3.1 of this document (TBD)
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
- CRYSTALS-Dilithium - [Dilithium][spec-crystals-dilithium]

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
[spec-crystals-dilithium]:
    https://www.pq-crystals.org/dilithium/data/dilithium-specification-round3-20210208.pdf

<reference anchor='CRYSTALS-Dilithium'
    target='https://doi.org/10.13154/tches.v2018.i1.238-268'> <front>
        <title>CRYSTALS-Dilithium: A Lattice-Based Digital Signature
        Scheme</title> <author initials='L.' surname='Ducas'
            fullname='Leo Ducas'> <organization>CWI</organization>
        </author> <author initials='E.' surname='Kiltz' fullname='Eike
        Kiltz'> <organization>Ruhr Universitat Bochum</organization>
            </author> <author initials='T.' surname='Lepoint'
        fullname='Tancrede Lepoint'> <organization>SRI
        International</organization> </author> <author initials='V.'
            surname='Lyubashevsky' fullname='Vadim Lyubashevsky'>
        <organization>IBM Research - Zurich</organization> </author>
        <author initials='P.' surname='Schwabe' fullname='Peter
            Schwabe'> <organization>Radboud University</organization>
        </author> <author initials='G.' surname='Seiler'
        fullname='Gregor Seiler'> <organization>IBM Research -
            Zurich</organization> </author> <author initials='D.'
        surname='Stehle' fullname='Damien Stehle'> <organization>ENS de
        Lyon</organization> </author> <date year='2018'/> </front>
            </reference>

## Appendix A.  Acknowledgements

We would like to especially thank Gabe Cohen for close attention to
and contribution to test vectors, and David Balenson for careful
review of approach. We would also like to thank Michael B. Jones 
for guidance in authoring.

## Appendix B.  Document History

-01

* Added Acknowledgements
* Added Document History
* Changed key type to MLWE
* Updated test vectors

-00

* Created draft-ietf-cose-dilithium-00 from
  draft-ietf-cose-post-quantum-signatures-01 following working group
  feedback

## Appendix C.  Test Vectors

### MLWE CRYDI5

#### publicKeyJwk
```json
{"kty":"MLWE","alg":"CRYDI5",
"x":"lgNFI62eq4YKxuvpMl2V9SVtGV5z_vQQZei\
\iCziAVcFMuUUzjpbwrd7uKHRbtxNPWsLIlfYKmM5SM-OLeoDII-GNQYJfm3QRt9l33P\
\AOyJpbeLidJg6e4UAIZJQx-KbKrIVqK6F42P8WmhDWxgc5xJZXUabUtMHV-irm9pMP8\
\kjrlRFuIenHS_YYj3RrX9yeAZKmD6YJsROVMEprjR1B7uOQxJYX1WNNRD5AEiGL8TKF\
\oxbOg-qDIP-M6ubjuKZqlhd3_-z1bLJDVkN_uh9hSIlqpghWD7niDldxKBAUldyELqn\
\WzvadJyhKTt3KevLOWGuPJGc927VgDnTVSvaiOW0bZu3wHEup5PxsqymxGEuJGkiY6Q\
\zL15KWzr4jdhq-_HpknGUjg2LbC0Q-f5raUm27vkT8EI7A3i-ar5Jhd9lhfXpGJ4Ui6\
\amgeTedhqJCKOzTrEF12ecwQ9ERhjdsksC8XMDe2lQS1W-AyHfntg2oPeC7O2q0E46J\
\MG_OUcLtMo3ShprY1VF93ObswsozfX6mmwqinQvYSpDAC7HHd39mp6CwJu10auoPi7H\
\DEAb0aSO-qUgdh8WOPgyCEe0GJ_Hpl7sokVq5dXtbV4458_zDtc-pUcX7C8J3OUgLfN\
\KsZzeOxQhgqkk0nG56CTleN_9u4rfWQzQZBH5ofr_biWHgr05HZ-UdjL4ezxPUIGW7M\
\_HvwktpowTnXfV4-6HTF16jqmH-AmO5XJlwjP44IbRMNk5m-vHOBJj6ELGiDuNQoiat\
\hKHS_-L0AO-7d2IxcpVuNWZfz1SvHzC4XPHt2lp0l_Rp9vu7obwGlFRrnLx1IrWcK6n\
\R3ux8oDJTM3H8J4cdRgzKaPM9_lBMhamWnpCXFThwRWshaTapgnLEfEXpMjikdho-SP\
\8DH6yddFrV-Sl_1Z8re1vD5CUXh50EcOepvnDYK5deW-Jqh6e_wGGlrwD7d9XZK9hKQ\
\oX1cYPsfkdgRIBywrD1bMIs7pyu5PVNSR39HD5woExp1y5bKgCaJDF-tBSl1tGQVl1U\
\pzENPHMi6fTCsv0OtEuvPZJkDvE-osJ_3Ajj9eTdKilJDdIYzSKu2Uodc96vaH3bXJW\
\05iBprV6h-nG6MuQuXIrUNiG9h8nQ7MmaJ_Jdr58_cBChxYZRu1zaJcSwpTecAtktv3\
\R-Yp2Lc7LxebwbEa19598X7CQtyS4RoUKorLOX4FkuXplJZduQbM2QftVqA6ufBkFH2\
\3Axy_fZooaz0oBM8YYBAIqJAs2Ya1iLfrdqo42rDL0K_VXmVGqctqKhM0etvM2nfx_8\
\VbsdoSmionB4d2Ur3no0AvzZbHcmIdHFg-EgJzfoIAhgKdHIzsN_AWEC9CFAp0dPwdi\
\MUs0sPhkWNAfs9hmnEX-IzxO57IyxE_iLkI9smuR6f2NkU23279NaZHBmIpmPU1tryg\
\SZ0i8yssFqKCDpRZwVV83F1Wcg3pnGsh9HXHC7rqI3-TB0_KxbTEmgKVspoido3Tl2Z\
\9Dx-9Jawe6rd7g1lheMOzlBWEfHFWwDTr5TxhEOo59zATIaJu4DxWkKfFQj4iXMYP-R\
\hA8QxNe82yUXoJGJo04f-C7N1xXJ64dOPoW0JNeDyM7liqtAQQgR6TNzVJvOb97E4Wl\
\AAC2gYfXGS8kOawcTyeWdytjXs8fqwOPJ3or2HZK1jnXZloGeSJILxHOQtl2PDM2k-W\
\0KZ1CPzbzjqQwQdg9CZ1F02b1Kusl42T2OjUylXsDGg4vaF-_IYucO7js31adyf90GZ\
\sMeoLqrwE1txMYJSk9SWSkjpL0csNDHH_sh5911O1ogQk6QoUIf_lMa-hg7EWKJAkP2\
\w2NsxPqr8vIAcdyCO_t5b6XpYCp7gkZiVxFn8tSrlofZbyW-zT1gp1gVEMhrWK5tIBZ\
\gE2ftMnG-AGekLYFD3aMzF3YZIDa3-Fs-_-YBOjx4ptOLCa8mXMUTj9s0KTXyB3BhYA\
\V7n8MDBRYITV17KMkLrY9vU1uhkxzSrNnBtSewEXf8Q4sGv2wEJjRJZyNPQzGtXRHNr\
\FKwCG3TVklCwc1d5C2Ttwh5HBtMtCBxTkAchRgRZshMWyVjnUiPn4rcGA-5XP6n8EZM\
\XOPo9vYkFuvb83GSB1g56jNCKGNStA-ZP33KKw_U8zdGz1fKX5xGvWrTU1MkhTST-aX\
\DHqpKjFTPU2M3wfraj37lfYK42rUYR-viKHyRXVH221DI6Ke-s1rKQxzSSHjSUBl3ID\
\eHtFb-pklL_JqIabpAKh_LkSthBvsiM1M8PUkiw30zzKQqScYiMxl_Ns3yvoahiWDh0\
\xO38smAiws9FjgI71mRywWBGJj4z21HTWfMAwWbzbld0MqZ4AW4zN6e-pMSfnPl-jF9\
\2C-FcXG58UQuBociY7Jwpg1XvWrVsTo3I8Qedzp1RYVV8qu3TQCCiCLom-UOwehbPdE\
\hp3ugI2nYjVygbk2QwseoRISKEylUlJ_vveItZCkinsK5Cy5g9OD59Ym4WzpdXjtRIP\
\k1ilfyLYcFwgdnNVLSNk1hb1iHgde9rghymzaUkEDdQwjfjXu8BsjKABdVyJwqF2r3g\
\V5UlK300F8Etd7n36y3RBxIx1fqkpCD-G-tePQ0zkbYwRouMC5P7Ws_Qj1WPAq9vIVF\
\WYDmRcXN4PKLb94qOQu8Ev2MfffDKDTvuPWU33UvOd3KbzKd3Jyfpq62WbeXEr_JgJ6\
\o442fEaWx4gh9tq1XZFQ4Wb9GzTuGz_hLkpCdOQd7snxiHPSxYqOjd9g8lYcsQKOhw_\
\dHCuSKyxxIAmI2MwLmGp6YnhY_JrfuUpZ1jfwcSCUqrzEvAS7CDvwzJ6-PAi2XO43ou\
\SP1-CGg9JS5hIiiIR5hpW3-Fqg2tOeqv7fFn_fAGyEtpHWDxkLJDTDcIzL2eU2umYUr\
\dbPynO9J99cEW3MU956D6LbmgRWK6lxQ5m539KMP7D4KQPPDt6CRA3YqAzZw-Vga8zd\
\2UxphCkORsaAs8pBihHwwe4ZhQl5qolmFKtQT2chnqVkn6nmpQmH3Th13XGf0RlByq-\
\bTEcwboddD_vYorb6HHyv9ciM0qh4g7tgmiphuR5b6LiVyqwxrMAN13cU8TiNIveY9A\
\fbS6qJMshNi61lkux4wnM6fpENDxCvRVCCyLB4NhS57fYddsTPiGZ6w1PeS_2Be8J9h\
\IN1g_yLmN8C1-9dgSx3yYYJZ4MGBNzxtbQIYcdH0_1mraXouf7hkhHAvbDPEcpCfUxt\
\mAI8hlYy-Pq1fjQTHoaEm9XaVe0SQfN6EsrbcXF2zjrG2uJuglRRM-IoWhleeMc1lv8\
\WCi33fB2KJhNo-iTKlhFYQmsO6qJyxusPu5Bmcl1EzONbBuHOeIHxzWBFoz5o4ziz3A\
\C1sD7eTc5-bF9enC-6J7OzRTx6mft5GwF8-FkQFJdqulPfgnr-_TYQZScKHW0Iki8kp\
\TUTr"}
```

#### privateKeyJwk
```json
{"kty":"MLWE","alg":"CRYDI5",
"x":"lgNFI62eq4YKxuvpMl2V9SVtGV5z_vQQZei\
\iCziAVcFMuUUzjpbwrd7uKHRbtxNPWsLIlfYKmM5SM-OLeoDII-GNQYJfm3QRt9l33P\
\AOyJpbeLidJg6e4UAIZJQx-KbKrIVqK6F42P8WmhDWxgc5xJZXUabUtMHV-irm9pMP8\
\kjrlRFuIenHS_YYj3RrX9yeAZKmD6YJsROVMEprjR1B7uOQxJYX1WNNRD5AEiGL8TKF\
\oxbOg-qDIP-M6ubjuKZqlhd3_-z1bLJDVkN_uh9hSIlqpghWD7niDldxKBAUldyELqn\
\WzvadJyhKTt3KevLOWGuPJGc927VgDnTVSvaiOW0bZu3wHEup5PxsqymxGEuJGkiY6Q\
\zL15KWzr4jdhq-_HpknGUjg2LbC0Q-f5raUm27vkT8EI7A3i-ar5Jhd9lhfXpGJ4Ui6\
\amgeTedhqJCKOzTrEF12ecwQ9ERhjdsksC8XMDe2lQS1W-AyHfntg2oPeC7O2q0E46J\
\MG_OUcLtMo3ShprY1VF93ObswsozfX6mmwqinQvYSpDAC7HHd39mp6CwJu10auoPi7H\
\DEAb0aSO-qUgdh8WOPgyCEe0GJ_Hpl7sokVq5dXtbV4458_zDtc-pUcX7C8J3OUgLfN\
\KsZzeOxQhgqkk0nG56CTleN_9u4rfWQzQZBH5ofr_biWHgr05HZ-UdjL4ezxPUIGW7M\
\_HvwktpowTnXfV4-6HTF16jqmH-AmO5XJlwjP44IbRMNk5m-vHOBJj6ELGiDuNQoiat\
\hKHS_-L0AO-7d2IxcpVuNWZfz1SvHzC4XPHt2lp0l_Rp9vu7obwGlFRrnLx1IrWcK6n\
\R3ux8oDJTM3H8J4cdRgzKaPM9_lBMhamWnpCXFThwRWshaTapgnLEfEXpMjikdho-SP\
\8DH6yddFrV-Sl_1Z8re1vD5CUXh50EcOepvnDYK5deW-Jqh6e_wGGlrwD7d9XZK9hKQ\
\oX1cYPsfkdgRIBywrD1bMIs7pyu5PVNSR39HD5woExp1y5bKgCaJDF-tBSl1tGQVl1U\
\pzENPHMi6fTCsv0OtEuvPZJkDvE-osJ_3Ajj9eTdKilJDdIYzSKu2Uodc96vaH3bXJW\
\05iBprV6h-nG6MuQuXIrUNiG9h8nQ7MmaJ_Jdr58_cBChxYZRu1zaJcSwpTecAtktv3\
\R-Yp2Lc7LxebwbEa19598X7CQtyS4RoUKorLOX4FkuXplJZduQbM2QftVqA6ufBkFH2\
\3Axy_fZooaz0oBM8YYBAIqJAs2Ya1iLfrdqo42rDL0K_VXmVGqctqKhM0etvM2nfx_8\
\VbsdoSmionB4d2Ur3no0AvzZbHcmIdHFg-EgJzfoIAhgKdHIzsN_AWEC9CFAp0dPwdi\
\MUs0sPhkWNAfs9hmnEX-IzxO57IyxE_iLkI9smuR6f2NkU23279NaZHBmIpmPU1tryg\
\SZ0i8yssFqKCDpRZwVV83F1Wcg3pnGsh9HXHC7rqI3-TB0_KxbTEmgKVspoido3Tl2Z\
\9Dx-9Jawe6rd7g1lheMOzlBWEfHFWwDTr5TxhEOo59zATIaJu4DxWkKfFQj4iXMYP-R\
\hA8QxNe82yUXoJGJo04f-C7N1xXJ64dOPoW0JNeDyM7liqtAQQgR6TNzVJvOb97E4Wl\
\AAC2gYfXGS8kOawcTyeWdytjXs8fqwOPJ3or2HZK1jnXZloGeSJILxHOQtl2PDM2k-W\
\0KZ1CPzbzjqQwQdg9CZ1F02b1Kusl42T2OjUylXsDGg4vaF-_IYucO7js31adyf90GZ\
\sMeoLqrwE1txMYJSk9SWSkjpL0csNDHH_sh5911O1ogQk6QoUIf_lMa-hg7EWKJAkP2\
\w2NsxPqr8vIAcdyCO_t5b6XpYCp7gkZiVxFn8tSrlofZbyW-zT1gp1gVEMhrWK5tIBZ\
\gE2ftMnG-AGekLYFD3aMzF3YZIDa3-Fs-_-YBOjx4ptOLCa8mXMUTj9s0KTXyB3BhYA\
\V7n8MDBRYITV17KMkLrY9vU1uhkxzSrNnBtSewEXf8Q4sGv2wEJjRJZyNPQzGtXRHNr\
\FKwCG3TVklCwc1d5C2Ttwh5HBtMtCBxTkAchRgRZshMWyVjnUiPn4rcGA-5XP6n8EZM\
\XOPo9vYkFuvb83GSB1g56jNCKGNStA-ZP33KKw_U8zdGz1fKX5xGvWrTU1MkhTST-aX\
\DHqpKjFTPU2M3wfraj37lfYK42rUYR-viKHyRXVH221DI6Ke-s1rKQxzSSHjSUBl3ID\
\eHtFb-pklL_JqIabpAKh_LkSthBvsiM1M8PUkiw30zzKQqScYiMxl_Ns3yvoahiWDh0\
\xO38smAiws9FjgI71mRywWBGJj4z21HTWfMAwWbzbld0MqZ4AW4zN6e-pMSfnPl-jF9\
\2C-FcXG58UQuBociY7Jwpg1XvWrVsTo3I8Qedzp1RYVV8qu3TQCCiCLom-UOwehbPdE\
\hp3ugI2nYjVygbk2QwseoRISKEylUlJ_vveItZCkinsK5Cy5g9OD59Ym4WzpdXjtRIP\
\k1ilfyLYcFwgdnNVLSNk1hb1iHgde9rghymzaUkEDdQwjfjXu8BsjKABdVyJwqF2r3g\
\V5UlK300F8Etd7n36y3RBxIx1fqkpCD-G-tePQ0zkbYwRouMC5P7Ws_Qj1WPAq9vIVF\
\WYDmRcXN4PKLb94qOQu8Ev2MfffDKDTvuPWU33UvOd3KbzKd3Jyfpq62WbeXEr_JgJ6\
\o442fEaWx4gh9tq1XZFQ4Wb9GzTuGz_hLkpCdOQd7snxiHPSxYqOjd9g8lYcsQKOhw_\
\dHCuSKyxxIAmI2MwLmGp6YnhY_JrfuUpZ1jfwcSCUqrzEvAS7CDvwzJ6-PAi2XO43ou\
\SP1-CGg9JS5hIiiIR5hpW3-Fqg2tOeqv7fFn_fAGyEtpHWDxkLJDTDcIzL2eU2umYUr\
\dbPynO9J99cEW3MU956D6LbmgRWK6lxQ5m539KMP7D4KQPPDt6CRA3YqAzZw-Vga8zd\
\2UxphCkORsaAs8pBihHwwe4ZhQl5qolmFKtQT2chnqVkn6nmpQmH3Th13XGf0RlByq-\
\bTEcwboddD_vYorb6HHyv9ciM0qh4g7tgmiphuR5b6LiVyqwxrMAN13cU8TiNIveY9A\
\fbS6qJMshNi61lkux4wnM6fpENDxCvRVCCyLB4NhS57fYddsTPiGZ6w1PeS_2Be8J9h\
\IN1g_yLmN8C1-9dgSx3yYYJZ4MGBNzxtbQIYcdH0_1mraXouf7hkhHAvbDPEcpCfUxt\
\mAI8hlYy-Pq1fjQTHoaEm9XaVe0SQfN6EsrbcXF2zjrG2uJuglRRM-IoWhleeMc1lv8\
\WCi33fB2KJhNo-iTKlhFYQmsO6qJyxusPu5Bmcl1EzONbBuHOeIHxzWBFoz5o4ziz3A\
\C1sD7eTc5-bF9enC-6J7OzRTx6mft5GwF8-FkQFJdqulPfgnr-_TYQZScKHW0Iki8kp\
\TUTr","d":"lgNFI62eq4YKxuvpMl2V9SVtGV5z_vQQZeiiCziAVcFVyXWhRDnGPXKI\
\-p70KAxRHm3Z7G8D21xfkTEWs04DNJgtnqBBjiKbqrqLXMEK5vvJe5W96PyYrlTbImN\
\DBL6yQ0ZIYBYJm4YtmygJAakg2bQoyRAwIzMgIpBBkAgAFJMg1MgMUBgEYoQhGUOMma\
\RloDABmgCKGhmN3IgQI4KECMExwBBNwoRlkhQpYbYwHKMFkaQtoaRgysBQm4YE1CYgQ\
\7hBAcaEAgOGHLAskqRBo0CQVKCMiKhx2wZkYAJkEQGNiihogoQoEQYKAYCISxJxWLhx\
\GZUlkkRFISQwGiVNA4WBJDCM0cZFE6VBGSWAWjKFWsSNUaYIRBAMGqFhWSAuYjaISMg\
\MowIlw0BloThlpLCRJDIqHAQAwwZgBMcRSRQNHCJywABJCCJsIbWNyIiIJEFiw0hwEj\
\Nug4RgSgAB2iAsgpRtYgCO1IAtHAIuUqIA3IIJ3MggyyBgGkWMm8QAhBaAgCJMScQkw\
\QCFk5RNxJRFCqkgHDVmwkhEBAFNnEQoo5YJyYBRg4QgCAiF4ZiNCRkgJIls24hB2Uhp\
\YsYBWkJtUrYx4TCGo7YlIDguXAZkAgWRY4QRgYBsoaiBA0JAkJCQ04Ask4IByyhiigK\
\BE8GQnAIAjAIp2ShlERCCGEEsUiJtkoiQErhpSYAxJAUEYwggEbKNoiIkEyMlTCBI4j\
\ZOXJAJ0cZsIkiADDIIGAJByBCFQwIuzLJQIKBIAyMAIUZJJLBlQAJhiCJtVMRpSARpg\
\LQAIrZI0iAImygl5MRpUpSF2aAJokYAwgRQIJBtAyhRkhhuQhZGEieKSIAsEbUwwjCE\
\0iQgVBBCCZRJWJRwC0ZG0SZl2rBBGKgo5CJEArFwSzBAG0hlkJQMGgclwgQm2AIqETE\
\kSYgtCLQpELFBGAIEwBhEysRQ2UgCkwgJgbhg2IYtFCZqEBZxoBJOpJIBjERpSahAwb\
\iMTKKIyihqwJKFGhCMwkBSUTaRiLSNjAKJoihwGchAy7JgAoYtSShyg8YNIEKI2hYhI\
\hdyCUVJ3CCSVIJgSDINgsKMkJCEoEYFACURwYBxQagJoIIIAZFBRMZxmCguIjMxo6KJ\
\U0AB07aN0qQQgzhtHKglCwYKCCZsUAhhlDYOgUYMSZaBlERBDEkpw7YtGgNOUqYFC6J\
\h2ZQNCQaBWCIhozIKDDhpZChuRIKA5AaFIhiREUlQJMAN1AZRlKhQYUJyGiFgGUdqQw\
\BS3IJhlCiGyoiFI7MApJKFWkANCzYSygQlkSgpnKSBikIqYiIFBLAkIcGMwrQJYCAkI\
\acEiSACyoJkCBQKQkIg4xZMECBgkphtBBgtmDQpCqWJIgAwCAWGIpEBIhaEXDYIUwRl\
\gAKBIaeQEoUglMgMgCZCGpcwwpQp2YKMyqaRCkhQowQB0YBBhBghC7lQRDYpFAghS8C\
\IAYclGDmSFCEQ2aaNgEBsygRBpBaFIRMs4xgMCUJgArVk3AJoEbkxCSBI4haCI5VJlJ\
\RQYyAFgSYJAUdJjAAqSyZRCgIQYiZJywYkUIaEAzYJWahBSwZOiTYgk4YpECcmCyFhE\
\wIxEjFy4jYQwTJwkAQEUqJMxChuDIkhCiBJiAhGmCBOgxQJTBJukzYkm4JomUZtHDeG\
\CAhpS6QkABUswMIFS6QgShgpmKYpwASE2hYIiwBIAzVgkERNZAYlGAlFg0BMQQRRWyi\
\OkohJERItyJhEE0NwkbREmJBFGgWIk0BhRBBOSgBNYRZJFKOITAJghARtIwVxmZaQCh\
\RpXBAMijJMYYAhkTQwibIxwTRCA8dNIJJgW5KNDJYAELiMoSCIGqZBVKAgSURtYDgMx\
\Dgk4IYgFCCEwhaG45IwY5CNzKJQIAUKBEQEoARmHCBJWDggm4YsyUAkUMQlXKAtwiJS\
\FKIMUjBpYgAJA8BFwzgIG0aRVBCIAsBBYIhkFLMgGCMqI0WCEjgAAJBtCZhBCSUQiyR\
\uUEItYkaK2agNAEQm4ESREhNmIreMAxYuETZpEyJBUAJuJBRu7kh_85-NnVU1ybdxVd\
\53EQwXd5rJr3r9DUZ9en2KzzPDgzcTPEBfQk6JsroofVPkTLuv91Qj4vyeB31IohvBL\
\bh8fqaYioveZBPNbp2I_J9RfRRCxdSXau28NFfYfc5aeDMHfOM_UKqIIu-hUZNtGUNR\
\NxS58X2hiJPFORu5EjJDMagA9tjYrRggbZuWkcpf67BUt2NMG68zIj27rB3tb3NwPzf\
\zr1PJ0uVn0q17uZr5HozPSJMHqUjfJFxeMLxLNpYfIyxkMjlKT_WsvQiWacudZKFWk6\
\IJhi8Pwp7wBXeF2zzDfZkpMtRKNeQxLGeJ5RCWqcW40FIOFzkVI1p-fckThXER0UXJL\
\j_5Od5_KhaZPO22eM3MM0AvDhg3ZcoKKGIOxtL9WGS3Cg5xMrtiJOwN42YyehXxGUN8\
\NYZL3nufSS0zslDq3SmQ6dM-SzsAB1oYw9g-DB07Y2xcPsNzH6QvcOc6oa9t0JK9RYF\
\BySCyH9ZSCwfij1FFD81Zgd8ociINcPU8BFV0WpnOcYdRWmzX6czabmaVWCdGcBfCIB\
\8kNw28PZhYmrzkgF3Ti8qDTCrZFMay1knaS0qRX3NDWIEs4fU_rYiMKsYi9dIEmXqPj\
\zknXYi-Sj21mjxliPWZkT1Iqbh7d14i-1C4c9WA5HCXPSPNa8VRb-dmVjdZ9ZBvlYzU\
\BiaRLfxwx6pbdslldHxDgFFBc8J9eDsH_-9dQgDmgGrgQgNI9ItlZwpvrTLb-n3YZmo\
\ZhCd0mWgTZnuMRSCmWPTj_2iHgtqX-EHj0hOjqXXfu7t54FMSgyKYMiu8q1_xm_Xztg\
\CPjE8tkCq1bAXZ-Vw4MXTf0ks9tiiUMExVLzT7hEgTVreYOqB_oToZVd_BVJqvbCNDe\
\GBp3Sd8q2VdWr_X3ISmr1SBacl7loRwsVElEEa6a_unR2Cpk9M_j9wMXAR_-0pnY0sO\
\GJKv9_1mWEMc8393npbg5P7I7cTS6bJOpcopRX2mlwof_QB65633bf51FBpmJ7qI-9e\
\iEz0EJ4o46RNo990ZEEJ6z7HLCE_IJJwnnRQbaNUPymZhoJ7ALMTxU-TODBL1jotS-_\
\2ZJPbS_yIOnx7sD1Gk4IqF39TDWUhqEdDbXR3laEJHTfeCezn32UBDuz_Jp3yl6nSrW\
\htiFk-gZPfHf-6cz8C1QCV7ezl_HiwIflF2RSVT3ZNkkisfkvRnwJpK_RS5H8jvvMR3\
\uVUE3MLVKznPg7Y5cbUERoCL_6DE6FHpZqPa6H0WKg7SE3bZpXbQiTnfo17kZqpYBCo\
\KBjDkHzQgMNnA-l1Z2Pdzkumgz_volZO8WuK2pNg47c44Yenm2RBxvag1KsI8ZWSK_n\
\Xia9yzygQHVh2h89MV2z1bynRinC5VysJ5KG1Zya_0jgLOmX0D1MG2m6mwmQ5OzHeJe\
\ymk87uzKJDfdCAcrUSRRlVyBFO4Fxe2fdl58q1ofIrI6S1juh0gb0wPryCy5Izh4aaP\
\gSpGYG7O6Eddi_8pdmIluXr7eSkwIqsQCT0eLYtXDmOWMmh5W4QDBZHrV_iA7nNM1PW\
\fynapnsoyiCewwqIeForRRbYEnMHUd5ksFYHlLtAbsqvB9oIm98crCkN3V0eWg8Tzti\
\f11S8JqD5G5QY8CdvxXzh5AeOIUziedqZd0trBhswRDpaM7n61vPt3wurgDgHktFJn1\
\VVQtgIEqjMFP_lWfrDWaVSCgd5ekSvuPmYdjatIp3v0N5uyj_GqkCU0O98X7NcyWfBA\
\gGtbTmn5yl25HFqPsLyGND0suzXjOeNX9N4e01u7d-Z57-9baO4sEJ1sHQ3PGTwc6Sa\
\Y1BR-EF79WZBES9VI0AElkSkdMHIAVAQ9-JJxxJgNbdcWLbmrdH5-fWtEKRYRoA9LOO\
\pe6ry1kBv3uOMqAKn7uneUrvADZmHxrVgAP1TV4OlYBdqOiz5QfauvgCM-V4S16D3Rd\
\Nr8KWbYOuqSVI2Jc12AAbcwBTMDq1AKpIXU8xE_LYjjXXaBhKbtvtN3Qh7l2ge-d7RD\
\DxefPqpafrQoa4KO_-YyfNgnIEG0lVWp3sZPenUnq2tEpgDAUIXcy2zMH4G5CmU_Ozb\
\fh9iT97h5K3LLG7JnM_E-jneyEO6KkYIHlvEUC5J4PC84ixUWqr7xNNfE2URYmhlE_s\
\VX5UZObF2MYRsOfb6dtVfojyliW_IN2n3KmggYfmVnQEl1XPC7dyN9gXfheu3agxDnw\
\UjqbRj79oQdxmXHOhzE2JzhcglYD9BSPyfRH8o1PnP86LRAVGaYUm8HILZ0ESEJ3PYq\
\P8K-uVY2P4Po8lbHgnFtH9U680jlqZ65rs1K5IKLctRZ7i58mO55jXAaEMpf0g-91Zy\
\imJkJO9DeZ6-sI66y2hw7ofAUK9ZboFxYNtIQKulbIrncUILwvDxTCHCy4QPX1hMVgc\
\6YF_vIrQFINILZ8tyYgqaoJlMd9YQEnGM9fqIWkcZtj4X1zJ-wFRxg_VXoT3thIHDuo\
\kd0p5WGmuY5kmpa0CmYG6ZZLYJMGsYzf-8OZm3t_4_AHZwCPXfui8kCFOP_0EJSvlWo\
\X_baoet6d4-u342BjgHnd9a2uOHqaZY_YHwdy3LxEVrusMxUqqUhjIPZfJJGhopUVOy\
\KRxyP6nFMY8Z4rAs5fkrtURL2mjOfDJBAW0o6i1tBTyscVfSHBayMffby2glDPzmH21\
\kSAffoWLRxo7pRm6TLXAjxTr4Rk-7CLQt8zURy8rdy815xvAEvtCweMeyWqjMDzJjI3\
\fX3jMr6Sjw_yQ7JOZ1VPBLa5APNJKt8ilKST01W_gQMPIoVDZSAdnmjq1EytPfXfDDq\
\CeC6l66qDuoxO7hOoHTrGZlztsduZsN7J8lRckp5AuBupmD3pQKeWRDKgoMxluTrt60\
\V_7HtORNg-NCiWSejw0YGrboqyShJ5efIV9vzmh6-N1X6y5s0GShHgiWIo8xYFdshP-\
\i1wzUoOAmPTaBiLHDjb0M7keH8HEpfmqnRWfIDZQ3T9xHIQXHcQYa8ggRGkAhcijr_x\
\qdYN58YmNDRR5IKAPisnfe6jRxhIQxE4Pvphmpq4pRRTD98Ui6AXbuMEQuzqHJe25O6\
\tgYIrvemsY2dtUZiMr5QzXDaAvWBJ2o60nlkWn2ucFATTjHipHLfs-tsuMova-XIKYo\
\VfJ3MeX3nxQHbMGzYhKT9YMYNRQ7Yo0nYcBraTia3bprcStwTySZgUP3l4ybRQJrcso\
\nwIVkl1C7XSaxKJhznwViTGpCSBwctn46yHMrlvvqNt8TCwClKk-8_OFsNxBhSjFxZC\
\Y6zq-HaQe0HP59tDDEuUAjkcgfGNh5Aj_JGrz1WVnyDVrXGXZ6BpzqPbJJypjXukZpv\
\U3yCcPNYVRKIUlstKFC43rN2XMQS-_K0NwGxbrHUiG01ApRg21AcLNjXQuO1_H5IMPP\
\fUMPwXZrLNIVBmJjTnylI8uNwBmU1WRF-2v_jfdVqPvdHZtw3xodWSZuZmzgMvMVL1l\
\sa78QCoZAqBEpqYEOxvwl99rlTPhnqHYM5Az41CWBY1co1AkCTfBpcBxKE9QdpvpIPH\
\U1diCScJfEq1f3A_pMr-HrWrmpnk-KXRBgogRp4Hjezk9HyhxTfQA00RcPQPuDvxfu1\
\EIVMhar4TdUjfA3OhQeigoXbRG9bC4fTJ6q3LiHAQRNgMzGIfwAZfgyTQXuAst4BvmH\
\cS45n-dl2eeye8i7gi5V0vnfqCdhzCMGHh9gt1Vg50stA93xBPLJVudYcwUDitSHSs3\
\AmakHXG8YHYOZuIJFvj_UtiMC7k4YMmF6ZTzOU2F7wmNgIdp1I-UqKPitk5BIWZbDpx\
\jSwyfjty5bfM4lsONII38-TFGF6cWnWC-QClBhxYsnl8cUfZwoEiShOPK4iy0pMVpYr\
\kfivcXzDYPfpWBEKE4BRcfRqrs4w5TK_zqLbt9tv8V_CLnJXEYmJrIdF6tVyIf2bGPK\
\p58YF8QuPjJArNc4qVC1R9yyKs7hxNb4WLaWsDQPYEYlbJeTJ8TsCPM7mSvp7F3weqi\
\AwbLAd5f8girEKeYSjx0jlK3zWbOBL7u_O7a8kJZYkt7L9sn5jnGumeLedvabOcWP-1\
\g6hCjHn1BvVpI66spO4i9OZSVMEpcXWWUUMrxG373uuZlAqVbQu6mYuMJNwavv4hf53\
\GwPRytC46rfTLIDvOBKVyTLRpGCQsWXqWw-IHAYLWoT00IZ695xePq5z03o-Sek-Kxj\
\UgGg91tIm74KuaMYIrMQCyNDv_-Qdj_OEDAxRj2V4w5TS3c04Dy2IPftmSjOxivXS8S\
\YJQNsncI1tXA2-di2gyvsr6qf2ae91QpCa0P3vW9golEgeO4Mq6lo4VAzaNrmPJhelL\
\aQyE_NsYEfJhvI9EAAAbg4Q28Dg1GSxErZHd4tgy82nRqlYdPFzjGUvYFzS4lePnQ"}
```

#### jws
```jws
eyJhbGciOiJDUllESTUifQ.OTA4NWQyYmVmNjkyODZhNmNiYjUxNjIzYzhmYTI1ODYyO\
\Tk0NWNkNTVjYTcwNWNjNGU2NjcwMDM5Njg5NGUwYw.8xELcU6FTHpMyTHwLqwmHJDck\
\Zdm7J6zLy1wT6XtW5zG9qBQoCP2dBULau1YkM7ZECnZ09h8XEa_7L8dfiIsOdWHdbOr\
\S5-OdQlDMbLEA8zgn8Jb12RyqH2Ehw9PsRCxp4BtyqvnZCnpV_UHykYdMVtUq2NKLT8\
\XrZfJWXcG4dzz-GddE6jJQPmKDzBQt0CsmaEwQl_WzN-167I0mPMmzwxOJcfjerWg6H\
\4wcwMj_0WPeAe5iMygAwCIIIFp72crFyLjWu3ziLojmKO65UL9_a99C_YbzagwNjYc7\
\2SJVYDcaDWiyajvnXfGM-e9hpMO-SeX79p-U8PlKNKBb8aPzP7LSUxrwCdf_xFPS68d\
\0QE6njannI7DbamW--LzMcRwKI6zUvdBVn0hYpM32fg2T-aOmW3KIL-aQZZ0wWH85OE\
\JVeUrSVX2uaGp2eFbNY6Y_C4OwByKLmE5OtrQUsLYwzkfHu9jaTWhBfUXhkdQLGy1qO\
\1xflJpbYfe4Doy7v0XfgDEYvGVYO-1PZ78d7WyrYLxJCSQGuuG8K2u7_g2QW0Rc5ESN\
\D4adRMMBBG0RfRJiXMN3Fem8Si2rV5k-eoT-sMs8lsQcLWEHWmS38hH4IuRtsUmfXnz\
\cq-X7mljwAKB6fnnU6poZvB0ag0MFNJha76N0fmdz3HeH4dK7f9DR2wt7pw_16h20SD\
\xASLLMTeIYPVN4Vzi63KfZ23FsXcnqBAwaK4ihBC7OLwUNkwfZo11OSxiVXlkO0eVqT\
\RiJe_VgDqxRk5sSgnaKBs_wklPeEG1K_cXLWcxp1akyC-e5kYdu3HX1g6Oo5MJdFPz0\
\E4JX5LCNU5w5CrkoJSKHCyys3KHCT6vmnpyMesJWhywuGPa0iS65Q2brkwCgqg-pUCJ\
\BeyqpzSVlJ-89xPPhU2BE6XSorXXAhrO9S_FehFw8ypNh2uS9S42Ul5vY4ccy-Jc6Tw\
\y4Pwqecsr7AlnSsvHDrUebItid2Pqa9DHa9gN_1zS6f-u9ne7tC7_PnYS9M5warHhDt\
\LTwm9k9z8bVtR7pHYKPWoutVtWaoI-Z0VVOvnZmKYL26gt1KJ7qUfvUOvzxNdkDHvV_\
\IQlAx9U_uQdrmOglz1F2Ia967tMA-x2xQtlNA0kcc6e8ZZeW40eG0xXJgV7pYmsGtPN\
\JvATmTCcEEqJ2rzG99PNAbNgon1UWz6-X3mRBXr5Kt75wP0I_IG3-k7SjqoTuOYmnOW\
\pzaIKlsG8wL_Vk0r3x1gN3DjBxuA6_LmU5RyyCPlfPB7ZtxJKSiB7O7IGLJBmeYVnAL\
\l1-24Nvy2jXjfeQJlJ8crOMQEglVliCci6XKmjtG_T8m5kTXrRL0yP64jir4M8H_tkL\
\TKCW1DH51K_U7genF9auecB8ASy8Uj9X129A2ccvP58PDYsP8YHpA5wsfixDtJotfLq\
\j3wsA-baB4hdQnhhZ0-K5Qufa8TIiCyyyIuJ1iV04IOsKWMAuW0ePGrFQwksba8GiW-\
\b15CXP8jC_DPtR6OULeaxLIBjtykIm_p0hL6JprKV8FAD6QFCMlyHapirma8ubLdyx9\
\p5c2STHq1UTCss8xTUyDcIz7oY_sVhk5Pelv5HFRpBRaoaVe2pcIcgAZ2uVOP8K09ne\
\WdbBOwKXwZmlVdnCLXe-ylscsb6NyvMEdMWSrerjSv2CSFA_HHfiKCYJ8BC_DPEUedv\
\nrAx4X0MGEnThIUah0AoRL41gp-AKuOp0lHftC2zBhHDxKeJpBS5UqTY7v8slTr6z1h\
\cGbLUaNzBC7U5QXxiHGZVtcN2s1W4v6ilEaOJKj72FUBt6ME9v22sGphJaDJ1iGfktr\
\LPSPAvp-6X6d0_pIbMydMyWABd-Ch9GOE4n-WX0cPUUIepm5loRUx7-dKG1MfmmU00q\
\dLlEw_Dwn299TGGKFyDVwnNCnGGEDKEfmqJcvUOCD_i5JChe4QKwuM7wU3KBOtDhQag\
\KLbIFa-4SZitqws8fn6TaH5DCi9E8JL7r3zvsfsJwj5-951ZIKTcB057cXynNkUT6C_\
\bucH1ReBj8n8mGp7ZtTNusV9OMManLzpDlizgUlwDi9Gv4rH6VqWuSndnozLKkzIdrj\
\a5iV9QuGgkuwCxkgcVC0Omixik9eBxkGdXbiUz8xdyYh21RLPLmHHELqqUUZMMcQGGF\
\Bg_DHozNMT48-1mS4MdkA8FUAaAUOxBPA9Qkanqh1AJQf2jnw63J-iK2A6U4l0cxpzE\
\-S2XXu51g6sgStI8iWrA8o3Xit8HenL_SNsNNk8tO_VwaO6Vj0poENkNqZS6MjSWR8y\
\nbvItMz8ANt8ZLhCAlJRxsFwG9-t3CHVb6GfsbPSe4H6UGG91y4sJ-Sbmebl9eMzxJD\
\ay2bi07C0IrRoWkAQsawu8Vbyyb8Pm40LqBgxbajimBELTDSNUZNMKHFw9uR5OQKXoe\
\Yaet_LCpRzAv-tj3JpC8vJYWMdPwpcheIVjOqw2abjOoNDNRFZNbCUAHLjeqEC01Nwx\
\kb1Nw_cUlGo4liuREMbgr9qqBpiELsr_qk9vIEB3AcgO7TJu-fq21jQ9AdKLHtyxHwz\
\jGLER3YwW7i3qqcKcoCJbv9PPaFD4Wob3tZ_OKi2mOKvHq8cIjyEb1xGdXt73T9cima\
\-dxshgiaayVzpMUSdVdHyvAfjK2JPpUEMJ-t3SCPN7QrPkmVhhUYCdxot3dIQ35TR4F\
\V9sp-52UckVckfLSPZmthJ2XAG_a2xt8Jnek8uhgYs1YhWkaCfbq-PVTGKLLGeDgIdc\
\W-vwzygAcMyMrH8CoSt6Zm3YLlpTaFN3eG0DJmvd7mSBcn7B_D7tQ2INEPK9YJKfjXs\
\JEfEIi88lp4ZkMk81Nv7k-Cs7m3Qi47HeMA6dcbLHpq30UtNCnEzgI2-S-ZIB-m9Tno\
\AenT3evvivdrK-B3Gg6n0N0xmhxM-jlH-Ad_9gio3Zqd0vIz6LSJZ6QbZmXewjCcehh\
\hiY8-iHWw3eYZ8MvxkfgcsBtkxu2jRhHYM-nftbFt6Cgd2Yu47P7lK9Als8lhG6gjao\
\hh_mVLq0BaHTrgQ7DO-D-9N-BJSrXWe-Ev6hx_NAQjmDuYa2ReGJnv0J1CHxeau9Bsw\
\ZzRB3EwcnlevorMhgDWSnOYmM60wGiwAswssoe17Df3wcdt-sDyPBUqVPRaXGm88GPV\
\xEJNESK6Zi92OH2r6u8JehAejnr2OKt3-sCEEDIpR6K8lgo-TaMTiF8WUylUWTfpym5\
\veaDqFmp_AooB_OqPLDCp1TLPetVImQh1T2tg0DM5AdtJuz2eQ-jog_ENCIeofo7Og_\
\QyTNR6RFGzlCVStRD7YGPozz_SC0Yn_sYpMpQ39glI0I36DXjdBOX3gcMN4esHXHHpS\
\YttwxegCuGMbOAzMgG-ZGpC1YC5NH9VGAa2kXQwzlzuAQZP6N5YAMNbn4jJnUqbSZ0i\
\GzN4zu7hEXlXOXvwVKLr4UJ1oxlIcVXVYFO_AjaRn-V4g7EdBCqA-FrlcXmLcGKuN2U\
\aX0Gj-qLn9bPOrz2GlkQy5QXy32axxurIJRpAbA6O-yclqy54jzto7fg5gn1VRggMKf\
\NPROZ9eyfQ_DmrH-60eoyJ1rDZ6NafR4gRwCXQt00F0Wze7H1bGpbbfrJbeXDbr9Lns\
\1EjHzaqyVstqpKOGcxQaDsdqNciHTo-mhKGqB2LgyQ4z4iIrcmaHEfc4NIUM_MghxPF\
\wi9w7kB89O0y41LUs6dHdu2ea-W1T_0mDXXdTW0fXNXQRdTKPwSSICi8vMMOBSn4k4F\
\or7n73x5Rvzv8OocHA3GeE0By8ymVxuyRq2csGv2nAMIH2f8erKxh4Id_foQbnJyQF_\
\sMZw1Fs6PC7UtRxLl6xgT7_Ynfhx-sgg38Ro_qMkwmJdBbwEPY4Vv-iu-PMKWpOXxQD\
\_oiTjS2yuf27B729ToREZc4hUUGNnhG_6cNsCn68W-E6s-koJRg633jMcHX3Sv0IFb6\
\DP3AggcLSaFd1s2V5zR4Y6PLUZHwg9M5kQbUl7zDpHwsI_ANmFMyf6KQU3XLiKq0g2k\
\cvP2RyGf5CDQk5HWVXXm7TDGv7AYPKThtU4Az00HRKN8UYPjPJuOv73DRNDvxEEYV32\
\hVlEyE3AYxRGrY6lOrAU1xXrATJBxJypIaaYXw-HVKwVcQYbbGyNCROUWRaR0aZ4LFX\
\MCLEElVs7G6I7pIguDWKCY702dpaxBKDIOKbUPlVwWF1qDdJ2sH2iCYdfK2OZfX0FiU\
\uK6JSaME4a2RGaT5uC7l2bGxw7zuK2n16xzH861vM_kVQzTMgYQhpS7to2_xnEvrQ0H\
\ogrSCf6Yd215g7NtTDMjo5GgBi1TwXUdyCmGHaoFZRDCrLsyw5G0vz1oOC29Hv28ecs\
\XtkFohjNNi_1Mw7wqBDMTRsLLb0pQ_LTMOZRwIaJfsGpa7FuCwvaQ8QTDfNMX1hdMzD\
\e-gNpeW9gWU6hlw_SXEWKyqpsxOjqWNpTQLCJFW4_54HmVjQGs-0JqUoRwXEmoxQnEh\
\5F5tOAepJuDeAaSnPcJHqC1G4WAPhIY4c2HiHlGHX1zjQnkMe7wmm1K5v7zsGxh1hCt\
\pw_yCVH7_i1fB38k8XKsq2-sVNCsUWYvqAe2hVdIwv4CVNvRohkxBn9uJ-76nTxPbL3\
\jJg5uUqD8kTpAv8LD0Hf3VlO7tYAMh4S6gbME7dw6I3UlcKAUmkXOs_AwbskXKL801q\
\CnZlZRpJoMXbL1e-nT40pAHSzDTiVb9fWWUF5d2aeylzQxW1ucbEhFTtJK1tGa0E1EV\
\Iz2_XfQu649ToHwsXJGiL_qLuX-v_HcO1hhm6d8_KYH1sXZm6sFVSp19QJPu5Xl6j6A\
\wSj4A1k56nVzCYL47fT-c087s_parbwfH0WdTEfaWflXEKRdqvIW4bhzLE08XIligw_\
\bd26QkWXWiK0CBaz_zNFptXbYIhjb599Ew_vN4jRRdU3k_UzUJIN6-3fMCImNgb8389\
\KSzsx2VRQWN3vP1QQcS3-oxTq-dks-PIA8G_GzO7bTYli9957dy3z9kO7Z6grSNu_eY\
\pmuROVhsc0Cr3OiXWSFpo8VkN49MAalSXlpNmQKQ9n9sYCebf1Mxz6KeTBInB4E_u5_\
\mz7JjoinhYBUIRgmGiDFVeOkfToZToG7Qf6F2f3M3XTMDkQBH93RJBhRWXjD4gUIjTB\
\vMehuU1Vz57CKRo1LAbiDb4f1mCrofTmXUvsX9zv7CWnMXnPgRmWVuHYsAoRgB6sNDE\
\kTwf82i6yubpBo9ZAwtsz72LjdsQbscn35hp9-qak3ZsRhstnyApD4il6TMze7smwNb\
\doDnXKmi56OP6-F2AcCNRqcDTXYZFfOC9qDVJQslKorZ8DGuwPNlIgnuozSTVzCNhQl\
\ZfpYEB19FL6SYKPe1XzgSQo6s-IKo_90KbMqMpPaMwgNjGMfYAKcX4SxlFzeoVuvgmS\
\5LEyJa_viB-lKbnrwbcaSj8pI_xqg8E2dBWu2YKJvcyxz7ZTF6YwySuVJHYIf0JVWsp\
\_vd_LUj6ySe2NAOsMq0xceJFM6ssfhURjsUGZcQ6prm18tlAKeyWhnWl-c0ALCDyNyX\
\UozNtO7kuCVFJtjEk5P9DdKdwgQaaTyErJcEA6fD3b3mfouZQ6PBQqTSAyEMrNARraA\
\78_1OpZEZgone5LN3e-mhFK-NpFhteOKzV870Air3dEXVo6RodykqYCH6dberJdzdcj\
\6COq6YRA8mdiXXcaZE6a1fkuEwRTFPBd9LZojPTfqh2ooo_MZ8h4qD-Ky4ixKZMWiwX\
\FAWE7JicpFC94bZqK_XQ78n9HIytd6gLh5UwIhHrShfNwOunnT0yaV4e_Abf73zxmV8\
\OryQvoaDobxAnsiEBE5B-7-QjSI-2MBm3meII1GMgz-jLtz4LoT1tBKgzxa1hS83s47\
\Ul2S0JtOnkstYtefZjKwsQOVsn3nS4ioYDn9J49tt2MEznMOKIAY3y3bypoFLlibeHN\
\pXs6A9wREKkfd1wC2ytSZ_G1x-IRBtwtWoictr7U2uY_QWSYnq2yEC8xfpmhz9kIFxx\
\ceZjN-QQna3xVZJWw3_0HDSQxatTXAA0cH3CPnLQAAAAAAAAAAAAAAAAAAAAAAAAJEB\
\ggJCoxOWV5SmhiR2NpT2lKRFVsbEVTVFVpZlEuT1RBNE5XUXlZbVZtTmpreU9EWmhOb\
\U5pWWpVeE5qSXpZemhtWVRJMU9EWXlPVGswTldOa05UVmpZVGN3TldOak5HVTJOamN3\
\TURNNU5qZzVOR1V3WXc
```



{backmatter}
