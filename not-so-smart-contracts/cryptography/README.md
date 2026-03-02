# (Not So) Smart Contracts (Cryptography)

This repository contains examples of common cryptographic vulnerabilities found in blockchain systems, featuring patterns from real security audits. Utilize the Not So Smart Contracts to learn about cryptographic pitfalls, refer to them during security reviews, and use them as a benchmark for security analysis tools.

## Features

Each _Not So Smart Contract_ consists of a standard set of information:

- Description of the vulnerability type
- Attack scenarios to exploit the vulnerability
- Recommendations to eliminate or mitigate the vulnerability

## Vulnerabilities

| Not So Smart Contract                                        | Description                                                                       |
| ------------------------------------------------------------ | --------------------------------------------------------------------------------- |
| [Timing Side-Channel Leaks](timing_side_channel)             | Non-constant-time crypto operations leak secret key bits via execution timing     |
| [Nonce and Randomness Reuse](nonce_reuse)                    | Reusing nonces in ECDSA or AEAD schemes breaks confidentiality and authenticity   |
| [Missing Secret Data Zeroization](missing_zeroization)       | Temporary secrets persist in memory after use, recoverable via dumps              |
| [Hash Domain Separation Failure](hash_domain_separation)     | Missing length or type prefixes cause hash collisions across different inputs     |
| [Underconstrained ZK Circuits](underconstrained_zk_circuits) | Insufficient constraints let a malicious prover forge zero-knowledge proofs       |
| [AEAD Metadata Authentication Failure](aead_misuse)          | Unprotected metadata in authenticated encryption allows undetected tampering      |
| [Weak Key Ratcheting](weak_key_ratcheting)                   | Static or epoch-bound keys lack forward secrecy and post-compromise security      |
| [DKG and MPC Protocol Flaws](dkg_mpc_protocol_flaws)         | Polynomial length, selective abort, replay, and DoS in distributed key generation |

## Credits

These examples are developed and maintained by **[Trail of Bits](https://www.trailofbits.com/)**.

If you have any questions, issues, or wish to learn more, join the #ethereum channel on the [Empire Hacking Slack](https://slack.empirehacking.nyc/) or [contact us](https://www.trailofbits.com/contact/) directly.
