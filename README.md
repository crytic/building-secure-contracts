# Building Secure Smart Contracts

![](https://github.com/crytic/building-secure-contracts/actions/workflows/slither.yml/badge.svg) ![](https://github.com/crytic/building-secure-contracts/actions/workflows/echidna.yml/badge.svg) ![](https://github.com/crytic/building-secure-contracts/actions/workflows/medusa.yml/badge.svg)

Brought to you by [Trail of Bits](https://www.trailofbits.com/), this repository offers guidelines and best practices for developing secure smart contracts. Contributions are welcome, you can contribute by following our [contributing guidelines](https://github.com/crytic/building-secure-contracts/blob/master/CONTRIBUTING.md).

**Table of Contents:**

- [Development Guidelines](./src/development-guidelines)
  - [Code Maturity](./src/development-guidelines/code_maturity.md): Criteria for developers and security engineers to use when evaluating a codebase’s maturity
  - [High-Level Best Practices](./src/development-guidelines/guidelines.md): Best practices for all smart contracts
  - [Incident Response Recommendations](./src/development-guidelines/incident_response.md): Guidelines for creating an incident response plan
  - [Secure Development Workflow](./src/development-guidelines/workflow.md): A high-level process to follow during code development
  - [Token Integration Checklist](./src/development-guidelines/token_integration.md): What to check when interacting with arbitrary tokens
- [Learn EVM](./src/learn_evm): Technical knowledge about the EVM
  - [EVM Opcodes](./src/learn_evm/evm_opcodes.md): Information on all EVM opcodes
  - [Transaction Tracing](./src/learn_evm/tracing.md): Helper scripts and guidance for generating and navigating transaction traces
  - [Arithmetic Checks](./src/learn_evm/arithmetic-checks.md): A guide to performing arithmetic checks in the EVM
  - [Yellow Paper Guidance](./src/learn_evm/yellow-paper.md): Symbol reference for easier reading of the Ethereum yellow paper
  - [Forks <> EIPs](./src/learn_evm/eips_forks.md): Summaries of the EIPs included in each Ethereum fork
    - [Forks <> CIPs](./src/learn_evm/cips_forks.md): Summaries of the CIPs and EIPs included in each Celo fork _(EVM-compatible chain)_
    - [Upgrades <> TIPs](./src/learn_evm/tips_upgrades.md): Summaries of the TIPs included in each TRON upgrade _(EVM-compatible chain)_
    - [Forks <> BEPs](./src/learn_evm/beps_forks.md): Summaries of the BEPs included in each BSC fork _(EVM-compatible chain)_
- [Not So Smart Contracts](./src/not-so-smart-contracts): Examples of common smart contract issues, complete with descriptions, examples, and recommendations
  - [Algorand](./src/not-so-smart-contracts/algorand)
  - [Cairo](./src/not-so-smart-contracts/cairo)
  - [Cosmos](./src/not-so-smart-contracts/cosmos)
  - [Substrate](./src/not-so-smart-contracts/substrate)
  - [Solana](./src/not-so-smart-contracts/solana)
- [Program Analysis](./src/program-analysis): Using automated tools to secure contracts
  - [Echidna](./src/program-analysis/echidna): A fuzzer that checks your contract's properties
  - [Slither](./src/program-analysis/slither): A static analyzer with both CLI and scriptable interfaces
  - [Manticore](./src/program-analysis/manticore): A symbolic execution engine that proves the correctness of properties
  - For each tool, this training material provides:
    - A theoretical introduction, an API walkthrough, and a set of exercises
    - Exercises that take approximately two hours to gain practical understanding
- [Resources](./src/resources): Assorted online resources
  - [Trail of Bits Blog Posts](./src/resources/tob_blogposts.md): A list of blockchain-related blog posts created by Trail of Bits

# License

secure-contracts and building-secure-contracts are licensed and distributed under the [AGPLv3 license](https://github.com/crytic/building-secure-contracts/blob/master/LICENSE). Contact us if you're looking for an exception to the terms.
