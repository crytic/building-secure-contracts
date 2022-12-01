# Building Secure Smart Contracts

![](https://github.com/crytic/building-secure-contracts/workflows/CI/badge.svg) ![](https://github.com/crytic/building-secure-contracts/workflows/Echidna/badge.svg)

Follow our guidelines and best practices to write secure smart contracts.

**Table of contents:**

- [Development guidelines](./development-guidelines)
  - [High-level best practices](./development-guidelines/guidelines.md): High-level best-practices for all smart contracts
  - [Incident Response Recommendations](./development-guidelines/incident_response.md): Guidelines on how to formulate an incident response plan
  - [Secure development workflow](./development-guidelines/workflow.md): A rough, high-level process to follow while you write code
  - [Token integration checklist](./development-guidelines/token_integration.md): What to check when interacting with arbitrary token
- [Learn EVM](./learn_evm): EVM technical knowledge
  - [EIPs - forks](./learn_evm/eips_forks.md): summarize the EIPs included in each fork
- [Not so smart contracts](./not-so-smart-contracts): Examples of smart contract common issues. Each issue contains a description, an example and recommendations
   - [Algorand](./not-so-smart-contracts/algorand)
   - [Cairo](./not-so-smart-contracts/cairo)
   - [Cosmos](./not-so-smart-contracts/cosmos)
   - [Substrate](./not-so-smart-contracts/substrate)
- [Program analysis](./program-analysis): How to use automated tools to secure contracts
  - [Echidna](./program-analysis/echidna): a fuzzer that will check your contract's properties.
  - [Slither](./program-analysis/slither): a static analyzer avaialable through a CLI and scriptable interface.
  - [Manticore](./program-analysis/manticore): a symbolic execution engine that can prove the correctness properties.
  - For each tool, this training material will provide:
    - a theoretical introduction, a walkthrough of its API, and a set of exercises.
    - exercises expected to require ~two hours to practically learn its operation.
- [Resources](./resources): Various online resources
   - [Trail of Bits blogposts](./resources/tob_blogposts.md) List of blockchain related blogpost made by Trail of Bits
