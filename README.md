# Building Secure Smart Contracts

This repository contains guidelines on how to write secure smart contracts, through best practices and usage of automated tools.


**Table of contents:**

- [Development Guidelines](./development-guidelines): List of best practices
- [Program analysis](./program-analysis): Training material on how to use automated tools to secure contracts.
  - [Slither](./program-analysis/slither): a static analyzer which can be used through a cli interface, or through its scripting capabilities.
  - [Echidna](./program-analysis/echidna): a fuzzer that will check your contract's properties.
  - [Manticore](./program-analysis/manticore): a symbolic execution engine which uses SMT solving to prove the correctness of execution.

For each tool:

- The content describes a theoretical introduction, a walkthrough of its API, and a set of exercises.
- The exercises are expected to require two hours.
