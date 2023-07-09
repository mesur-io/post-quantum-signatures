%%%
title = "JOSE and COSE Encoding for Falcon"
abbrev = "jose-cose-falcon"
ipr= "trust200902"
area = "Internet"
workgroup = "COSE"
submissiontype = "IETF"
keyword = ["JOSE","COSE","PQC","FALCON"]

[seriesInfo]
name = "Internet-Draft"
value = "draft-ietf-cose-falcon-latest"
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

This document describes JSON and CBOR serializations for Falcon,
a Post-Quantum Cryptography (PQC) signature suite.

This document does not define any new cryptography, only seralizations
of existing cryptographic systems.

This document registers key types for JOSE and COSE, specifically `NTRU`.

Key types in this document are specified by the cryptographic algorithm
family in use by a particular algorithm as discussed in RFC7517.

This document registers signature algorithms types for JOSE and COSE,
specifically `FALCON1024` and others as required for use of various
parameterizations of the Falcon post-quantum signature scheme.

FALCON is described and noted as a part of the
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

# Falcon

## Overview

This section of the document describes the lattice signature scheme
[@!Falcon], the "Fast Fourier lattice-based compact signatures over
NTRU". Falcon is based on the GPV hash-and-sign lattice-based signature
framework introduced by Gentry, Peikert and Vaikuntanathan [GPV08],
which is a framework that requires a class of lattices and a trapdoor
sampler technique. For the class of lattices, Falcon uses the well-known
NTRU lattices, while for the trapdoor sampler, it uses a new fast
Fourier sampling technique [DP16]. The underlying hard problem is the
short integer solution problem (SIS) over NTRU lattices, for which no
efficient solving algorithm is currently known for both classical as
well as quantum settings.

The main design principle of Falcon is compactness, i.e. it was designed
in a way that achieves minimal total memory bandwidth requirement (the
sum of the signature size plus the public key size). This is possible
due to the compactness of NTRU lattices. Falcon also offers very
efficient signing and verification procedures. The main potential
downsides of Falcon refer to the non-triviality of its algorithms and
the need for floating point arithmetic support.

The GPV framework, which underpins the Falcon design, is proven to be
secure in the (quantum) random oracle model as long as the SIS problem
remains intractable. Falcon requires an adaption of this prove to
account for the fact it uses NTRU lattices.

Falcon brings several advantages over other approaches to signature
suites:

- Post-quantum secure as long as the NTRU-SIS problem remains
  intractable.
- Compactness: Falcon aims at minimum signature plus public key sizes.
This should be contrasted with hash-based signature schemes (e.g.
SPHINCS+), which minimizes public key sizes but suffer from long
signatures, and multivariate quadratic schemes, which minimizes
signatures sizes but suffers from long public keys. It also offers
substantially shorter signatures than other lattice schemes while public
keys are about the same size.
- Efficiency: Falcon can produce thousands of signatures per second on a
common computer, while verification is up to ten times faster. The
operations in Falcon have O(n log n) complexity for degree n.
- Side-channel resistance: Falcon may still have an important limitation
regarding side-channel attacks due to the hardness of implementing
discrete Gaussian sampling over the integers in constant-time. This gap
that may have recently filled, but is under active investigation.

## Core Operations

Core operations used by the signature scheme should be implemented
according to the details in [@!Falcon]. Core operations include key
generation, sign, and verify.

## Using FALCON with JOSE

This sections is based on [CBOR Object Signing and Encryption (COSE) and
JSON Object Signing and Encryption
(JOSE)](https://datatracker.ietf.org/doc/html/rfc8812#section-3)

### FALCON Key Representations

A new key type (kty) value "NTRU" (for keys related to the family of
algorithms that utilize NTRU based approaches to Post-quantum lattice
based cryptography) is defined for public key algorithms that use base
64 encoded strings of the underlying binary material as private and
public keys and that support cryptographic sponge functions. It has the
following parameters:

- The parameter "kty" MUST be "NTRU".

- The parameter "alg" MUST be specified, and its value MUST be one of
  the values specified the below table

| alg         | Description                         |
| ----------- | ----------------------------------- |
| FALCON512   | Falcon with parameter set 512       |
| FALCON1024  | Falcon with parameter set 1024      |

- The parameter "pset" MAY be specfied to indicate the parameter set in
  use for the algorithm, but SHOULD also reflect the targeted NIST level
  for the algorithm in combination with the specified parameter set. For
  "alg" "FALCON" one of the described parameter sets "512" or "1024"
  MUST be specified. Parameter set "512" or above SHOULD be used with
  "FALCON" for any situation requiring at least 128bits of security
  against both quantum and classical attacks

- The parameter "x" MUST be present and contain the public key encoded
  using the base64url [@!RFC4648] encoding.

- The parameter "d" MUST be present for private keys and contain the
  private key encoded using the base64url encoding. This parameter MUST
  NOT be present for public keys.

Sizes of various key and signature material is as follows

| Variable    | Paramter Name | Paramter Set | Size |
| ----------- | ------------- | ------------ | ---- |
| Signature   | sig           | 512          | 666  |
| Public Key  | x             | 512          | 897  |
| Private Key | d             | 512          | 1281 |
| Signature   | sig           | 1024         | 1280 |
| Public Key  | x             | 1024         | 1793 |
| Private Key | d             | 1024         | 2305 |

When calculating JWK Thumbprints [@!RFC7638], the four public key fields
are included in the hash input in lexicographic order: "kty", "alg", and
"x".

When using a JWK for this algorithm, the following checks are made:

- The "kty" field MUST be present, and it MUST be "NTRU" for JOSE.

- The "alg" field MUST be present, and it MUST represent the algorith
  and parameter set.

- If the "key_ops" field is present, it MUST include "sign" when
  creating an NTRU signature.

- If the "key_ops" field is present, it MUST include "verify" when
  verifying an NTRU signature.

- If the JWK "use" field is present, its value MUST be "sig".


### FALCON Algorithms

In order to reduce the complexity of the key representation and
signature representations we register a unique algorithm name per pset.
This allows us to omit registering the `pset` term, and reduced the
likelyhood that it will be misused. These `alg` values are used in both
key representations and signatures.

| kty         | alg           | Paramter Set |
| ----------- | ------------- | ------------ |
| NTRU        | FALCON512     | 512          |
| NTRU        | FALCON1024    | 1024         |

## Using FALCON with COSE

The approach taken here matches the work done to support secp256k1 in
JOSE and COSE in [@!RFC8812].

The following tables map terms between JOSE and COSE for signatures.

| Name       | Value | Description                    | Recommended |
| ---------- | ----- | ------------------------------ | ----------- |
| FALCON512  | TBD   | Falcon with parameter set 512  | No          |
| FALCON1024 | TBD   | Falcon with parameter set 1024 | No          |

The following tables map terms between JOSE and COSE for key types.

| Name   | Value | Description                           | Recommended |
| ------ | ----- | ------------------------------------- | ----------- |
| NTRU   | TBD   | kty for NTRU based digital signatures | No          |

# Security Considerations

The following considerations SHOULD apply to all parmeter sets described
in this specification, unless otherwise noted.

Care should be taken to ensure "kty" and intended use match, the
algorithms described in this document share many properties with other
cryptographic approaches from related families that are used for
purposes other than digital signatures.

## Falcon specific Security Considerations

Falcon utilizes floating point multiplications as part of fast Fourier
transforms in its internal operations.  This is somewhat novel and care
should be taken to ensure consistent implementation across hardware
platforms.  Well tested underlying implementations should be selected
for use with JOSE and COSE implementations.

## Validating public keys

All algorithms in that operate on public keys require first validating
those keys. For the sign, verify and proof schemes, the use of
KeyValidate is REQUIRED.

## Side channel attacks

Implementations of the signing algorithm SHOULD protect the secret key
from side-channel attacks. Multiple best practices exist to protect
against side-channel attacks. Any implementation of the the
Falcon signing algorithm SHOULD utilize the following best practices at 
a minimum:

- Constant timing - the implementation should ensure that constant time
  is utilized in operations
- Sequence and memory access persistance - the implemention SHOULD
  execute the exact same sequence of instructions (at a machine level)
  with the exact same memory access independent of which polynomial is
  being operated on.
- Uniform sampling - care should be given in implementations to preserve 
  the property of uniform sampling in implementation.

## Randomness considerations

It is recommended that the all nonces are from a trusted source of
randomness.

# IANA Considerations

The following has NOT YET been added to the "JSON Web Key Types"
registry:

- Name: "NTRU"
- Description: NTRU family post-quantum signature algorithm key pairs
- JOSE Implementation Requirements: Optional
- Change Controller: IESG
- Specification Document(s): Section 3.1 of this document (TBD)

The following has NOT YET been added to the "JSON Web Key Parameters"
registry:

- Parameter Name: "pset"
- Parameter Description: The parameter set of the crypto system
- Parameter Information Class: Public
- Used with "kty" Value(s): "NTRU"
- Change Controller: IESG
- Specification Document(s): Section 2 of this document (TBD)

The following has NOT YET been added to the "JSON Web Key Parameters"
registry:

- Parameter Name: "d"
- Parameter Description: The private key
- Parameter Information Class: Private
- Used with "kty" Value(s): "NTRU"
- Change Controller: IESG
- Specification Document(s): Section 2 of RFC 8037

The following has NOT YET been added to the "JSON Web Key Parameters"
registry:

- Parameter Name: "x"
- Parameter Description: The public key
- Parameter Information Class: Public
- Used with "kty" Value(s): "NTRU"
- Change Controller: IESG
- Specification Document(s): Section 2 of RFC 8037

The following has NOT YET been added to the "JSON Web Signature and
Encryption Algorithms" registry:

- Algorithm Name: "FALCON512"
- Algorithm Description: FALCON512 signature algorithms
- Algorithm Usage Location(s): "alg"
- JOSE Implementation Requirements: Optional
- Change Controller: IESG
- Specification Document(s): Section 4.1 of this document (TBD)
- Algorithm Analysis Documents(s): (TBD)

The following has NOT YET been added to the "JSON Web Signature and
Encryption Algorithms" registry:

- Algorithm Name: "FALCON1024"
- Algorithm Description: FALCON1024 signature algorithms
- Algorithm Usage Location(s): "alg"
- JOSE Implementation Requirements: Optional
- Change Controller: IESG
- Specification Document(s): Section 4.1 of this document (TBD)
- Algorithm Analysis Documents(s): (TBD)

# Appendix

- JSON Web Signature (JWS) - [RFC7515][spec-jws]
- JSON Web Encryption (JWE) - [RFC7516][spec-jwe]
- JSON Web Key (JWK) - [RFC7517][spec-jwk]
- JSON Web Algorithms (JWA) - [RFC7518][spec-jwa]
- JSON Web Token (JWT) - [RFC7519][spec-jwt]
- JSON Web Key Thumbprint - [RFC7638][spec-thumbprint]
- JWS Unencoded Payload Option - [RFC7797][spec-b64]
- CFRG Elliptic Curve ECDH and Signatures - [RFC8037][spec-okp]

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
[DP16]: Leo Ducas and Thomas Prest. Fast fourier orthogonalization. In
    Sergei A. Abramov, Eugene V. Zima, and Xiao-Shan Gao, editors,
    Proceedings of the ACM on International Symposium on Symbolic and
    Algebraic Computation, ISSAC 2016, Waterloo, ON, Canada, July 19-22,
    2016, pages 191-198. ACM, 2016.
[GPV08]: Craig Gentry, Chris Peikert, and Vinod Vaikuntanathan.
    Trapdoors for hard lattices and new cryptographic constructions. In
    Richard E. Ladner and Cynthia Dwork, editors, 40th ACM STOC, pages
    197-206, Victoria, BC, Canada, May 17-20, 2008. ACM Press.

<reference anchor='Falcon' target='https://falcon-sign.info/'> <front>
    <title>Fast-Fourier Lattice-based Compact Signatures over
        NTRU</title> <author initials='P.' surname='Fouque'
        fullname='Pierre-Alain Fouque'> </author> <author initials='J.'
        surname='Hoffstein' fullname='Jeffrey Hoffstein'> </author>
        <author initials='P.' surname='Kirchner' fullname='Paul
        Kirchner'> </author> <author initials='V.'
        surname='Lyubashevsky' fullname='Vadim Lyubashevsky'> </author>
        <author initials='T.' surname='Pornin' fullname='Thomas Pornin'>
        </author> <author initials='T.' surname='Prest' fullname='Thomas
        Prest'> </author> <author initials='T.' surname='Ricosset'
        fullname='Thomas Ricosset'> </author> <author initials='G.'
        surname='Seiler' fullname='Gregor Seiler'> </author> <author
        initials='W.' surname='Whyte' fullname='William Whyte'>
        </author> <author initials='Z.' surname='Zhang'
        fullname='Zhenfei Zhang'> </author> <date year='2017'/> </front>
        </reference>

## Test Vectors

### NTRU FALCON512

#### publicKeyJwk
```json
{"kty":"NTRU","alg":"FALCON512","x":"CjcORWYeLyAc5OSAR5tLh2bn0KXRcAP\
\cAssTZu2nYLIatsrnlb2j23yBKQNdC_ak2axFDLyj8QeWtIyNphAjVTqC8Nfz6cuoHA\
\GIPMV7rwWxd0WYYJTWUZUHJbJGIo75KV7-eQGQ2KUDcyQgjhcBWCxOwPxyYUN1EC138\
\onR_xvcakAhjagU1GNowliiWVwEoVvK8oPtE-m8Wz8u4TfQ6wRorRZ1MsQENBHesWEt\
\5H5UIGYhyck7hXVF4FHpLFEIvxSTjDUm3OZQXEmRM_4WARVQQnya7MM3Z6FIzJvoPV7\
\IXGBqsaLrqwCpH9PBkECjzK4YIilVDA5iUR9gdbjAmjJqSgpHfmFWi9OGlhARYI-j12\
\t8f3KykkFlyqHUuhulI7Y7Az3nAwXgePqsise7fSMIssXmtaFUag4g0k1QBklpwUiY4\
\h9aNN4SjYKZQO7m1ZU9YJK7bVG3hmlaAKDiUXmas0tUTkh8Kld_oFS9BtOX15Q2oOEq\
\Yd6YAJhY5lebavuaVtWTO9U4uzhPQtljcoRZkITdB8igKbrjxgxFdJ6mU1IuvFpE6eQ\
\qAZ4M6U6jRVmzWZRScP0C0WXSPnlxrfJ1bEvhXNIepUmLsjjWKFuMbYcEjo2e4g85KA\
\2bBsgfmqoUVE7M7KHrqUKdMZjkXd0nOaEg41gRmSUC3ASK2oqlWhV1H1KlrzDF01hBp\
\L3yErDiT_Ng4Q6yrcE9rjAv2qSdigBwK3Jujeh50GFr5eKZR1570OlApp_Bs5v17CqJ\
\8Q3VSUbKu0WT2HybcjOKpgnm0WM8Zn6IxeA9AOTfc8CRNwUMwZYWoLVSmvkBTYAAUSK\
\EGmmRy6cCXZJ9zv580TOQ5Bm-bMSnydrY4ZOlaWthXDElEWMFK23zQyYHkPzG1JvIuf\
\AUagNCQGQUy1_iWdpNOZ5DlDSJ1CIpWHASdrvnJ5gqUeYh-_1Bt7wVV9rknBQHQKe6c\
\9rxgJhLq0erQ4BkyaDwWF6EDMUDJ9gLE2oDcnYJK6KuBsTjzZRIPWi5TANMQQWgZlgC\
\mVeZQ_Zt6wB46mHKFxMzkQgIwPLVmVLt5dWJS1Cf8Bn13yYqc0R59cifsW61GTnmiqk\
\LLKeU6Iu3eWo2OLhHXIUSLeGJWwYV2HzjNirrV12LdRzo9oqkb_EiLagseRL6s4vaPq\
\BB9uIvQYuRDXRJxJUNSj2yNREPNDCICOAiJYRx1ZHCS_46kGKkDs04t4Z1SAdGXWAEw\
\Ns4o-GWwjKyok6EYT1pa5mc6CEdp5N3A2h6kvxRPSZcD8EfKB3cWzQsbWkGbvoNXaxa\
\HWkbEa0kZIDgKiRiInC-iVoRzqqXRBKFBMLG6QPJm61pK2VLxrJCjP9qw193OOyUKif\
\QzgswOnYwDamsekYHOAmfL2b_kciRZl6EaVSlbnCYBkLVyiU0uTrcigrWLRtG1OJUkN\
\iYCVF2AGx8TihI86WV3BZFCrVNjsyqucRhmOxxd6RqEZTge7i4bzWx4zAKzRZKJyovV\
\1VtoX8Ct36hVtXVKsFn9vxqz6OdZtaWV12PG7CFCLGVnYKCONsX2s9YHo2AhxXRE74s\
\hAUaD2APOKPXT0laA_BvgcssHJ3Jqsdy72JTImu24-mYpFLn8PIAk0Y8AGGnYmFNXdI\
\z6ONvSxnH6T-oapAGJ8EYaTtsXDy25cJkaUyBanxiIW20CuoDVzu7jiPjwUuGLMUc27\
\EpJAr2fGT3A5okzEdXN-Iiof3iwm5GfBUNRkLiD_kbIve4nOb_RkEVkRDY2i51fRKwk\
\BxTptO3Po6rlZRKyr4SDgaNNwVljxc-Rcy7V9RDWkjqesoR_SkNy_e-lBev8DexEAHX\
\crqhqifuLCa0fzn5GC6t-ai0my_tvMTKVsMBfW11SRfYKtw3vILELOLGJirsl1zGyZp\
\wYHmHK9Fk0TPLnystG67flhWb0RM4awAyh4UZUK1QYWyEk-okmRtSmbJCCkoXFcRX5J\
\BlElSMgWGaKGLt9AYA0fMoRNMStBXHU9dTJ0V2oLvITAfgS3K0aHEW7kI0shtPP6SPh\
\XyYql-ijPQ3aPBBldkhfi21WiDBmhLA-yxUxcrVlZ2NkZtj34Qch0rzQoNLLVDpqLsm\
\Z9yRNiXzEMxEaKmY5rXhngKhBcXuRP2p7SUZN5L6pEqaYncYWqUi4XAD1iYHxngDBdL\
\kKyUhqWDcRZacAKLuK5NWjcNXce5RNDVMti5WfguGRNZ5Qu8xsK6X1Ez9k0lNKVTUnV\
\SQtBbFbGYwIFNl3KYcgHEbMpSS5p6oYQhHl_8eqqIrWCvrC413ENMeFnHRsqrErnlZw\
\SmSz4BDFA0GcuyNvVWt5_BUKx94IqY2ra_LQ-Lz8j5JDSzNxWJORBAA2S8o3m1teTEg\
\KANewDdZTcvsVA0"}
```

#### privateKeyJwk
```json
{"kty":"NTRU","alg":"FALCON512","x":"CjcORWYeLyAc5OSAR5tLh2bn0KXRcAP\
\cAssTZu2nYLIatsrnlb2j23yBKQNdC_ak2axFDLyj8QeWtIyNphAjVTqC8Nfz6cuoHA\
\GIPMV7rwWxd0WYYJTWUZUHJbJGIo75KV7-eQGQ2KUDcyQgjhcBWCxOwPxyYUN1EC138\
\onR_xvcakAhjagU1GNowliiWVwEoVvK8oPtE-m8Wz8u4TfQ6wRorRZ1MsQENBHesWEt\
\5H5UIGYhyck7hXVF4FHpLFEIvxSTjDUm3OZQXEmRM_4WARVQQnya7MM3Z6FIzJvoPV7\
\IXGBqsaLrqwCpH9PBkECjzK4YIilVDA5iUR9gdbjAmjJqSgpHfmFWi9OGlhARYI-j12\
\t8f3KykkFlyqHUuhulI7Y7Az3nAwXgePqsise7fSMIssXmtaFUag4g0k1QBklpwUiY4\
\h9aNN4SjYKZQO7m1ZU9YJK7bVG3hmlaAKDiUXmas0tUTkh8Kld_oFS9BtOX15Q2oOEq\
\Yd6YAJhY5lebavuaVtWTO9U4uzhPQtljcoRZkITdB8igKbrjxgxFdJ6mU1IuvFpE6eQ\
\qAZ4M6U6jRVmzWZRScP0C0WXSPnlxrfJ1bEvhXNIepUmLsjjWKFuMbYcEjo2e4g85KA\
\2bBsgfmqoUVE7M7KHrqUKdMZjkXd0nOaEg41gRmSUC3ASK2oqlWhV1H1KlrzDF01hBp\
\L3yErDiT_Ng4Q6yrcE9rjAv2qSdigBwK3Jujeh50GFr5eKZR1570OlApp_Bs5v17CqJ\
\8Q3VSUbKu0WT2HybcjOKpgnm0WM8Zn6IxeA9AOTfc8CRNwUMwZYWoLVSmvkBTYAAUSK\
\EGmmRy6cCXZJ9zv580TOQ5Bm-bMSnydrY4ZOlaWthXDElEWMFK23zQyYHkPzG1JvIuf\
\AUagNCQGQUy1_iWdpNOZ5DlDSJ1CIpWHASdrvnJ5gqUeYh-_1Bt7wVV9rknBQHQKe6c\
\9rxgJhLq0erQ4BkyaDwWF6EDMUDJ9gLE2oDcnYJK6KuBsTjzZRIPWi5TANMQQWgZlgC\
\mVeZQ_Zt6wB46mHKFxMzkQgIwPLVmVLt5dWJS1Cf8Bn13yYqc0R59cifsW61GTnmiqk\
\LLKeU6Iu3eWo2OLhHXIUSLeGJWwYV2HzjNirrV12LdRzo9oqkb_EiLagseRL6s4vaPq\
\BB9uIvQYuRDXRJxJUNSj2yNREPNDCICOAiJYRx1ZHCS_46kGKkDs04t4Z1SAdGXWAEw\
\Ns4o-GWwjKyok6EYT1pa5mc6CEdp5N3A2h6kvxRPSZcD8EfKB3cWzQsbWkGbvoNXaxa\
\HWkbEa0kZIDgKiRiInC-iVoRzqqXRBKFBMLG6QPJm61pK2VLxrJCjP9qw193OOyUKif\
\QzgswOnYwDamsekYHOAmfL2b_kciRZl6EaVSlbnCYBkLVyiU0uTrcigrWLRtG1OJUkN\
\iYCVF2AGx8TihI86WV3BZFCrVNjsyqucRhmOxxd6RqEZTge7i4bzWx4zAKzRZKJyovV\
\1VtoX8Ct36hVtXVKsFn9vxqz6OdZtaWV12PG7CFCLGVnYKCONsX2s9YHo2AhxXRE74s\
\hAUaD2APOKPXT0laA_BvgcssHJ3Jqsdy72JTImu24-mYpFLn8PIAk0Y8AGGnYmFNXdI\
\z6ONvSxnH6T-oapAGJ8EYaTtsXDy25cJkaUyBanxiIW20CuoDVzu7jiPjwUuGLMUc27\
\EpJAr2fGT3A5okzEdXN-Iiof3iwm5GfBUNRkLiD_kbIve4nOb_RkEVkRDY2i51fRKwk\
\BxTptO3Po6rlZRKyr4SDgaNNwVljxc-Rcy7V9RDWkjqesoR_SkNy_e-lBev8DexEAHX\
\crqhqifuLCa0fzn5GC6t-ai0my_tvMTKVsMBfW11SRfYKtw3vILELOLGJirsl1zGyZp\
\wYHmHK9Fk0TPLnystG67flhWb0RM4awAyh4UZUK1QYWyEk-okmRtSmbJCCkoXFcRX5J\
\BlElSMgWGaKGLt9AYA0fMoRNMStBXHU9dTJ0V2oLvITAfgS3K0aHEW7kI0shtPP6SPh\
\XyYql-ijPQ3aPBBldkhfi21WiDBmhLA-yxUxcrVlZ2NkZtj34Qch0rzQoNLLVDpqLsm\
\Z9yRNiXzEMxEaKmY5rXhngKhBcXuRP2p7SUZN5L6pEqaYncYWqUi4XAD1iYHxngDBdL\
\kKyUhqWDcRZacAKLuK5NWjcNXce5RNDVMti5WfguGRNZ5Qu8xsK6X1Ez9k0lNKVTUnV\
\SQtBbFbGYwIFNl3KYcgHEbMpSS5p6oYQhHl_8eqqIrWCvrC413ENMeFnHRsqrErnlZw\
\SmSz4BDFA0GcuyNvVWt5_BUKx94IqY2ra_LQ-Lz8j5JDSzNxWJORBAA2S8o3m1teTEg\
\KANewDdZTcvsVA0","d":"WiAGIXAgz4HzCD33-d9wvue8JPxC-AIO-EEIN-__Gx9AI\
\g_gB3Ih-AIHfc0MQf-AL4v7L7wdfAAYOhEL__jEP4idAXX_f_0AAmF7v9mAMpQfB8nM\
\ED7pPh173wi90IA_KIIQ-D8IRf4T_hjCLyCD58PQd98w_A8MIwh9_wAB8QJBb___dk-\
\Mmeh8EIwA73wwb4EXgfEUgP-8D_viEPwBg94H_hIPIfeED2wD_7wwBAIPdDB4fggH_3\
\wAJ8YBbCEPxc6L_fhEIASd8Dnfh__mgi__4_eEH5Q7IEiv-_4PQ9EQBObAMBfl1_4fh\
\GkgA_-fn_CAEBu_Frv-jDwJOeIL4_cB7g_5CH_xB-EPyC3_3RDEDgN7FgAgb70PAj_8\
\XSB8DwvgAHwRc8D5wDEEPQEEL5CAHwXwhH8XNgKDggE0AGi_7coP_GUG_hFwAQCH73w\
\cEMnh_EEZSB6QG_87_4PA7_2QfKEI--Dz3_-AIIvDDwfii2EZAB4EIyBCL-y_IHwQh-\
\L_ygKIg-jKDoe_-IJgB-Dvu-CEPwA-AZf_-MPvCKIBRf8YHRE8L3vAAD3Ah8Eg-E6MP\
\wiIH_U8OLZP-EEgAjCDvRkIMIPgBz3fC6QHA9IJCPE-EQQE6AgQ-__-wh90XvB6IQAE\
\AL4Ri934Oh4MPyC30eejB_4g9D__vhGIXiE-MHwi-ARAhBsYQZ-HgO-6XwAkF04PbCA\
\AxfGTXdmF4IvaP4Hx8CIfOBAL4eeGAXw_H33xdGAY-A-EJRbIEYv_GAX_B_3wxhAAHR\
\e8ERjDDwJP_EDWwfCAwdi4Pv-k9_5fCD7XdhEEPwg-AffC7_3AcB4wQ_BwPu9F74d9J\
\wX_eB_f-cIHnvgF0n_AB7_tf_z_wfBv3B_7_wO9ALxfCCUJgg_35BbCHfe_4EQiD3zQ\
\_a78HthGXZeB9wAsg4EYBCCIBN_wH_SB_4PieH8HBcGLwfBTvnf--IAPe_3YA-8Dge_\
\KE4CC0X_ygyL_h74P4ff9sOyB98AwBMIPxiMDAfjCEIvBF8HR-F8Pf9__3xc8HgPgEX\
\3wfF7wvlED_RBB8P-CP8HS86DwRZ5_4vn9_vuCAHQg-IMQMACIPxD8PofkFwYPfB_wP\
\kD3_wA__2_i7zgh_-YgfgD_5ScH8Ht_CPQP-AHo_DAL2gh8D__dCPngc78nQAAMHwhB\
\7f-9_wYwjEHQCDHvwPgIMYiaEHgt8CLwc_ML_A9F0Qxl6AIyiGL3yB8APC-AEgQE93f\
\g92EQCBH4XO-B8Ygd1sJv_GDv-8CT4_k__aAc8DwgkD_H_i9wAPhAEAfh4D4f-CAPxB\
\AEY-9AAHjd_zXhjELpfdAToAn-cvwi8YYAfEUg_FH_v_gJ4Hw9AAQgCGHgej93wO-D8\
\ohg-EXh_EMH-7GL4Q-4EAOi5sQ-hBkQAlHsBgg2P4x_IA397ED2xcAMWxA5sPBX9vvf\
\ACX3heCDwR_AEQ-g6P4gBwHn-94AIBi8MXff4EHPCDwey8H_4x95_gBe-IPxaAEYxeG\
\HgwgCHw99J3YNgJ83wDJ4ARjJ4Oh-18exez_wRgEAIBeAf3vjGDoffAMH_a6P_P9GP4\
\Ph8EgwZGAofk5wfiB_3fAeMAGwi8MAOHD8HgfF8AehCDo_A4LYA_MHvyi_74BE70v_7\
\AEIS_D_oAED0gPi-Mv-eCEJBhB3pC_94wMiB8ARF6AAOh4TwCB__RO-LDH1_h_05_8O\
\19gT8-QaAPLq7xvz5gop5Qf--Of-JBQKDxP_8eXU-Qwl2Q_uzO7lAObM-evnKd7lQPc\
\CFQfsLOb-4dI0-Q0SEhPs0hsBQxTh1uwRA-QS9QYBFv8KAwIU4er8HAAOHOALBvTnDv\
\gK9-P3yiA48gcOCxYs2vAG9OgnGiTMEysU29r9-uIS8dX5--0E9P71_gI2IDUK7-HZF\
\_UE3fL80uEK7vX_1BfbASAK6QPpAwP5B-nsQOcJ7QH_MgH2ycgrQSX1CVgn9QwAuvwi\
\7BLdGR4f70DS-gAQ7-MQGygSJAYMAu3y8CUGDywPBSwl-xEXG_vYDv3PEQj8FgX60xP\
\_9ifi1O34Dvv5CPvVEhDY-gYHEwTC7P8R6-HJENojDBMMGuks_cvoIQgP9_cA4wYWF_\
\T3FwbX3hznHOgpFiL03-sF7uYi-g3g6vAT59z5GAET_BzpCN0GAwkHHtgTIPr55d0LE\
\AwD7iME__khGQYYK93c0Cza9OEN2fHt8vM0_wT88ukP7Ov8AfU8GgjtFQPh8Qbu6gjv\
\8_AISA8m6iz3_w00Aesb5O8HFQ4zAegODxIMBPcCHuzm-yfbBvvr5vP0A9fewOkRAuU\
\HBssYFrkjERIZ9h3r8CPo3dso9gUK9ecJ8toQ2CEe2f3hEBLz7wASDwMbBvYCFPsl-w\
\r49tvp9CgE-xQT8PUQGdviBxnY1xwWBdX-CAvxJu4MLgP07x7oKOzW8REIORUM-vsQE\
\PLi9Qj94u_3CezpABPk1AwZBAXbKOcn4O76F-4W5w4uzPfqJw4qAfcm-vLVIu3FF_H4\
\9N7CHvIJ6AzwAPkA-w_UCiz4FT4D5-IBAukSEAIR-vDr8wPpBsgKA_3_5v4LDxMX4fk\
\bBw7wBvYNBAAC4_UU7Q7uKM3x_g0BD_3m5xn86wQH4e786O8hAfQR4_0DDg717N_0Fd\
\73E-sBIAP1ABH99BcgAyfH_-vS7uLcB-3u5fjvIfAyERbtB_8g_SEu__zvNRzrAA798\
\TLu9RLU-BP7DRbnC-kmxAcAQRDsFwvuGxf5A_QA3BTnAtXuFNv48ePawvi_GfHwGfHT\
\NPL7--nj_Rzu3AnsCuoTJAX07Q_q-fH7BCcXHOzzHOcs-eDYE-A1J_H39t3-zPgUBx0\
\I30oSMAUH9vMS1BAC9vob_vMRATHmBfv48R_ZAu7k39spBvUU5xX5ACwB-fv-Hu8JHQ\
\DoJecN7eAzJuDuDhkTE_YT-dS7-gYaFCLg9fcO5RT-6h0WISJBAOtY5BkLsvoX4gThG\
\TEEOPQQ-v_gA_sP9BYk_AsI_N8EGxUIHAny5A4J6k769_MB6-8Z5wb6BSkp8vn4FBQK\
\9_XZ9-YUCP4AJA"}
```

#### jws
```jws
eyJhbGciOiJGQUxDT041MTIifQ.OTA4NWQyYmVmNjkyODZhNmNiYjUxNjIzYzhmYTI1O\
\DYyOTk0NWNkNTVjYTcwNWNjNGU2NjcwMDM5Njg5NGUwYw.9AQ6wQ1M_MmPTDw7hPx_Z\
\905wyLaeoXIFfI_hQr97PwDG9uzKFKZTotDdde_4_zuBTc2u25bdkf9JCm2m6QVzYza\
\O83MVOGzGLiqICdSm1WxOHP_7bT9w4fMGq2PcOzMaak9wNG6pFblUnciqruqaJcv9DX\
\q00tZs6efS2d2LT3FSmkMzC7rSTypHF2bp3PsxJHox33Z3uVDTxxHTZt8hFW8DUJLBD\
\Nt5p2IG2Kde50a2VIHhUnYnaSaZb9HHR2PQ4Myv5irbJfsoRjNJ5Mxe62sqGnKxOXjj\
\q_BRfTtjKSp9V5ZGkccNjPTXIZZ9jCqGS-tzNoXzMDBYnmU4gqa11UFTfCOhVsSqeIl\
\9NNVe6_8zZxaQUt5qE1cj76P4n-onBEkb_RTE7xuhJ3Re9lGW-dRRVOJAYXVJv_bkx2\
\QrUOZNp97TajO0bODnETJwm7Mt1nzorVYfNBkbd5FkIPX872zJNJtyuTRNUcVCyT7mK\
\MK7EQ1qA52yZR1HEnTg9OaffxQsTG1_3cjnM94_NG8IsvjwxKcTO0O626pvoZ2mnysr\
\wYhZ0C8tMlPOUrMnSLDQcIpRGDMqV5YEltokXFdTdGrZ6Em4yXleIiZkFDzKPvDc8LO\
\WpbBf_tcrrzuT3G_yhJFsTquL0z-bsjaKf45tjCKw5GhoOiSi1M6hDUsm7TLSjyyyxV\
\1Iiakh2k67tN42MWBlpcdBrKavE_ZN1VZwpjnzNdBL0izesskTk7-UE3_hy6UyKbLeg\
\BfdusKv83Er7lp_oVdYorMQVCNzl9GPVQdnd8SA17VpZgraUHu-aAcVKdlr4XaWLdO8\
\FMPC1moVTny2SHKe-BK4xTPbdtpawprm1aYsWW4zaUhMdgZNtPQnGIy06bl8UUbJEJW\
\O0olG2Uu3cnPfIYLgUXM_FYrUetHpp2G7NG3KrwBeumirL0D1YUnTEIsf2dRyMbBfGi\
\9NFqziixaursfgXijDuq-q6PQqAv9h_TikSMbElHa9qi-a-VVbmsT0UisEldN6yk5OO\
\tTFmsqcecBiVTdukZXR8yG8SJUDt23fIb0z_Idj5TnFLiRbYLjaWgNyz-aw_hxBNOMg\
\cQ9ughpAMjIFNarTpPTLDv_n9JHUMJe_m1abZJy9tKFaxCIIExw3cvyaORIkN1a_r9S\
\SIoVAjRkmATi06v10lxjy6jMlT--MN3J2RYGFuttORy5LG9WPR8fF1f768iVD40a80O\
\QI7A_dd3bmFlMY5lpSW_dvW5pG4Vyc5kvvh0k59gYVoJJfJEjzpoZQUFtuzlFI3slVz\
\a07WJo3SRopHMARrkOlwnLXD0e4iLJrx6XHav2bVT3vxqVTacIC4b461AUHQVhzcX3T\
\uTzGTs6kHF4jrMFNDNbXOPVDvtoGriHtu-FNYVdOjSTHBcIhn0p-fzaAxKDIvVsSSim\
\pXn9hJfdJTQ0_duWWXgtZaXibdpBikU3nk90puTUttVUJJuXSxK2TTpT-JIRwkcVpBo\
\s37kK8myWo8Qo4b29hBs1RcClD1PjXfRvpEX7bfVuhaY9ZVu6cHmdRK_RKvwqfyMASX\
\nMit_doSmbnBrpWelzdcZpyOg9s7xCIUVjZhCYegS5otA4ygmvxu69BBcem00aGGJ3h\
\fnysq4Ep0uMzQgS6dafqdQFJwsPZmLGBocYPKgTHIRNWfZCzzrqNZ7-hYYhcNWp5AAA\
\AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA\
\AAAAAAAAAAAAAZXlKaGJHY2lPaUpHUVV4RFQwNDFNVElpZlEuT1RBNE5XUXlZbVZtTm\
\preU9EWmhObU5pWWpVeE5qSXpZemhtWVRJMU9EWXlPVGswTldOa05UVmpZVGN3TldOa\
\k5HVTJOamN3TURNNU5qZzVOR1V3WXc
```



{backmatter}
