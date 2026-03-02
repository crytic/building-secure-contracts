# (Not So) Smart Contracts (Merkle Tree)

This section contains examples of common vulnerability patterns found in Merkle proof verification systems, including airdrops, whitelists, and on-chain distribution mechanisms. These issues arise from incorrect proof verification logic, missing access controls, and insufficient context binding.

## Features

Each not-so-smart-contract includes:

- Description of the vulnerability type
- Attack scenarios to exploit the vulnerability
- Solidity code examples demonstrating the flaw
- Recommendations to eliminate or mitigate the vulnerability

## Vulnerabilities

| Name                                                                 | Description                                                                           |
| -------------------------------------------------------------------- | ------------------------------------------------------------------------------------- |
| [Empty Proof Bypass](./empty_proof_bypass)                           | Verification accepts empty proof arrays, allowing any leaf to validate as the root    |
| [Leaf-Node Hash Collision](./leaf_node_collision)                    | Identical pre-hash sizes for leaves and internal nodes enable second preimage attacks |
| [Missing Claim Replay Protection](./missing_claim_replay_protection) | Absence of claim tracking allows the same proof to be used multiple times             |
| [Arbitrary Proof Length](./arbitrary_proof_length)                   | Accepting proofs of any length enables collision attacks or denial of service         |
| [Missing Root Validation](./missing_root_validation)                 | Proof verified against a user-supplied root instead of the stored root                |
| [Missing Leaf Context](./missing_leaf_context)                       | Leaves without chain ID or contract address enable cross-chain replay                 |
| [Inverted Verification Logic](./inverted_verification_logic)         | Negated boolean in proof verification accepts invalid proofs                          |
| [Unauthorized Root Update](./unauthorized_root_update)               | Missing access control on root update functions allows arbitrary root replacement     |

## Credits

These examples are developed and maintained by **[Trail of Bits](https://www.trailofbits.com/)**.

Contact us if you need help with smart contract security.
