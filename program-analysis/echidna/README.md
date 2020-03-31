# Echidna Tutorial

The aim of this tutorial is to show how to use Echidna to automatically test smart contracts.

The first part introduces how to write a property for Echidna.
The second part is a set of exercises to solve.

**Table of contents:**

- [Installation](#installation)
- [Introduction to fuzzing](./fuzzing-introduction.md): Brief introduction to fuzzing
- [How to test a property](./how-to-test-a-property.md): How to test a property with Echidna
- [How to filter functions](./filtering-functions.md): How to filters the functions to be fuzzed
- [How to test assertions](./assertion-checking.md): How to test Solidity's `assert` with Echidna
- [How to collect a corpus](./collecting-a-corpus.md): How to use Echidna to collect a corpus of transactions
- [Exercise 1](./Exercise-1.md): Testing token's balance
- [Exercise 2](./Exercise-2.md): Testing access control
- [Exercise 3](./Exercise-3.md): Testing with custom initialization
- [Exercise 4](./Exercise-4.md): Testing with `assert`

Join the team on Slack at: https://empireslacking.herokuapp.com/ #ethereum

## Installation

Echidna can be installed through docker or using the pre-compiled binary.

### Echidna through docker

```bash
docker pull trailofbits/eth-security-toolbox
docker run -it -v "$PWD":/home/training trailofbits/eth-security-toolbox
```

*The last command runs eth-security-toolbox in a docker that has access to your current directory. You can change the files from your host, and run the tools on the files from the docker*

Inside docker, run :

```bash
solc-select 0.5.11
cd /home/training
```

### Binary

[https://github.com/crytic/echidna/releases/tag/1.4.0.0](https://github.com/crytic/echidna/releases/tag/1.4.0.0)

solc 0.5.11 is recommended for the exercises.
