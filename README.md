# Building Secure Smart Contracts

![](https://github.com/crytic/building-secure-contracts/workflows/CI/badge.svg) ![](https://github.com/crytic/building-secure-contracts/workflows/Echidna/badge.svg)

This repository, brought to you by [Trail of Bits](https://www.trailofbits.com/), outlines guidelines and best practices to write secure smart contracts.

We welcome contributions, and you can contribute by following our [contributing guidelines](https://github.com/crytic/building-secure-contracts/blob/master/CONTRIBUTING.md).

**Table of contents:**

- [Development guidelines](./development-guidelines)
  - [Code Maturity](./development-guidelines/code_maturity.md): Criteria for developers and security engineers to use when evaluating a codebase’s maturity
  - [High-level best practices](./development-guidelines/guidelines.md): High-level best-practices for all smart contracts
  - [Incident Response Recommendations](./development-guidelines/incident_response.md): Guidelines on how to formulate an incident response plan
  - [Secure development workflow](./development-guidelines/workflow.md): A rough, high-level process to follow while you write code
  - [Token integration checklist](./development-guidelines/token_integration.md): What to check when interacting with arbitrary token
- [Learn EVM](./learn_evm): EVM technical knowledge
  - [EVM Opcodes](./learn_evm/evm_opcodes.md): Details on all EVM opcodes
  - [Transaction Tracing](./learn_evm/tracing.md): Helper scripts and guidance for generating and navigating transaction traces
  - [Yellow Paper Guidance](./learn_evm/yellow-paper.md): Symbol reference for more easily reading the Ethereum yellow paper
  - [Forks <> EIPs](./learn_evm/eips_forks.md): Summarize the EIPs included in each Ethereum fork
    - [Forks <> CIPs](./learn_evm/cips_forks.md): Summarize the CIPs and EIPs included in each Celo fork _(EVM-compatible chain)_
    - [Upgrades <> TIPs](./learn_evm/tips_upgrades.md): Summarize the TIPs included in each TRON upgrade _(EVM-compatible chain)_
    - [Forks <> BEPs](./learn_evm/beps_forks.md): Summarize the BEPs included in each BSC fork _(EVM-compatible chain)_
- [Not so smart contracts](./not-so-smart-contracts): Examples of smart contract common issues. Each issue contains a description, an example and recommendations
  - [Algorand](./not-so-smart-contracts/algorand)
  - [Cairo](./not-so-smart-contracts/cairo)
  - [Cosmos](./not-so-smart-contracts/cosmos)
  - [Substrate](./not-so-smart-contracts/substrate)
  - [Solana](./not-so-smart-contracts/solana)
- [Program analysis](./program-analysis): How to use automated tools to secure contracts
  - [Echidna](./program-analysis/echidna): a fuzzer that will check your contract's properties.
  - [Slither](./program-analysis/slither): a static analyzer available through a CLI and scriptable interface.
  - [Manticore](./program-analysis/manticore): a symbolic execution engine that can prove the correctness properties.
  - For each tool, this training material will provide:
    - a theoretical introduction, a walkthrough of its API, and a set of exercises.
    - exercises expected to require ~two hours to practically learn its operation.
- [Resources](./resources): Various online resources
  - [Trail of Bits blogposts](./resources/tob_blogposts.md): List of blockchain related blogposts made by Trail of Bits

# License

secure-contracts and building-secure-contracts are licensed and distributed under the [AGPLv3 license](https://github.com/crytic/building-secure-contracts/blob/master/LICENSE). Contact us if you're looking for an exception to the terms.
