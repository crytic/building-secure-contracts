# Building Secure Smart Contracts

![](https://github.com/crytic/building-secure-contracts/actions/workflows/slither.yml/badge.svg) ![](https://github.com/crytic/building-secure-contracts/actions/workflows/echidna.yml/badge.svg) ![](https://github.com/crytic/building-secure-contracts/actions/workflows/medusa.yml/badge.svg)

Brought to you by [Trail of Bits](https://www.trailofbits.com/), this repository offers guidelines and best practices for developing secure smart contracts. Contributions are welcome, you can contribute by following our [contributing guidelines](https://github.com/crytic/building-secure-contracts/blob/master/CONTRIBUTING.md).

**Table of Contents:**

- [Development Guidelines](./development-guidelines)
  - [Code Maturity](./development-guidelines/code_maturity.md): Criteria for developers and security engineers to use when evaluating a codebase’s maturity
  - [High-Level Best Practices](./development-guidelines/guidelines.md): Best practices for all smart contracts
  - [Incident Response Recommendations](./development-guidelines/incident_response.md): Guidelines for creating an incident response plan
  - [Secure Development Workflow](./development-guidelines/workflow.md): A high-level process to follow during code development
  - [Token Integration Checklist](./development-guidelines/token_integration.md): What to check when interacting with arbitrary tokens
- [Learn EVM](./learn_evm): Technical knowledge about the EVM
  - [EVM Opcodes](./learn_evm/evm_opcodes.md): Information on all EVM opcodes
  - [Transaction Tracing](./learn_evm/tracing.md): Helper scripts and guidance for generating and navigating transaction traces
  - [Arithmetic Checks](./learn_evm/arithmetic-checks.md): A guide to performing arithmetic checks in the EVM
  - [Yellow Paper Guidance](./learn_evm/yellow-paper.md): Symbol reference for easier reading of the Ethereum yellow paper
  - [Forks <> EIPs](./learn_evm/eips_forks.md): Summaries of the EIPs included in each Ethereum fork
    - [Forks <> CIPs](./learn_evm/cips_forks.md): Summaries of the CIPs and EIPs included in each Celo fork _(EVM-compatible chain)_
    - [Upgrades <> TIPs](./learn_evm/tips_upgrades.md): Summaries of the TIPs included in each TRON upgrade _(EVM-compatible chain)_
    - [Forks <> BEPs](./learn_evm/beps_forks.md): Summaries of the BEPs included in each BSC fork _(EVM-compatible chain)_
- [Not So Smart Contracts](./not-so-smart-contracts): Examples of common smart contract issues, complete with descriptions, examples, and recommendations
  - [Algorand](./not-so-smart-contracts/algorand)
  - [Cairo](./not-so-smart-contracts/cairo)
  - [Cosmos](./not-so-smart-contracts/cosmos)
  - [Substrate](./not-so-smart-contracts/substrate)
  - [Solana](./not-so-smart-contracts/solana)
- [Program Analysis](./program-analysis): Using automated tools to secure contracts
  - [Echidna](./program-analysis/echidna): A fuzzer that checks your contract's properties
  - [Slither](./program-analysis/slither): A static analyzer with both CLI and scriptable interfaces
  - [Manticore](./program-analysis/manticore): A symbolic execution engine that proves the correctness of properties
  - For each tool, this training material provides:
    - A theoretical introduction, an API walkthrough, and a set of exercises
    - Exercises that take approximately two hours to gain practical understanding
- [Resources](./resources): Assorted online resources
  - [Trail of Bits Blog Posts](./resources/tob_blogposts.md): A list of blockchain-related blog posts created by Trail of Bits

# License

secure-contracts and building-secure-contracts are licensed and distributed under the [AGPLv3 license](https://github.com/crytic/building-secure-contracts/blob/master/LICENSE). Contact us if you're looking for an exception to the terms.
