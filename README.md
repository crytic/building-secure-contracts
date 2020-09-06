# Building Secure Smart Contracts

![](https://github.com/crytic/building-secure-contracts/workflows/CI/badge.svg)

Follow our guidelines and best practices to write secure smart contracts.

**Table of contents:**

- Development guidelines
  - [Secure development workflow](./development-guidelines/workflow.md)
  - [High-level best practices](./development-guidelines/guidelines.md)
  - [Token integration checklist](./development-guidelines/token_integration.md)
- [Program analysis](./program-analysis): How to use automated tools to secure contracts
  - [Slither](./program-analysis/slither): a static analyzer avaialable through a CLI and scriptable interface.
  - [Echidna](./program-analysis/echidna): a fuzzer that will check your contract's properties.
  - [Manticore](./program-analysis/manticore): a symbolic execution engine that can prove the correctness properties.

For each tool, this training material will provide:

- a theoretical introduction, a walkthrough of its API, and a set of exercises.
- exercises expected to require ~two hours to practically learn its operation.
