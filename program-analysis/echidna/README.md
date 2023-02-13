# Echidna Tutorial

The aim of this tutorial is to show how to use Echidna to automatically test smart contracts. 

Watch our [Fuzzing workshop](https://www.youtube.com/watch?v=QofNQxW_K08&list=PLciHOL_J7Iwqdja9UH4ZzE8dP1IxtsBXI) to learn through live coding sessions.

**Table of contents:**

- Introduction
  - [Installation](#installation)
  - [Introduction to fuzzing](./fuzzing-introduction.md): Brief introduction to fuzzing
  - [How to test a property](./how-to-test-a-property.md): How to test a property with Echidna
- Basic
  - [How to select the most suitable testing mode](./testing-modes.md): How to select the most suitable testing mode
  - [How to select the best testing approach](./common-testing-approaches.md): How to select the best testing approach
  - [How to filter functions](./filtering-functions.md): How to filters the functions to be fuzzed
  - [How to test assertions](./assertion-checking.md): How to test assertions with Echidna
  - [How to write good properties step by step](./property-creation.md): How to iteratively improve property testing
  - [Frequently Asked Questions](./frequently_asked_questions.md): Answers to common questions about Echidna
- Advanced
  - [How to collect a corpus](./collecting-a-corpus.md): How to use Echidna to collect a corpus of transactions
  - [How to use optimization mode](./optimization_mode.md): How to use Echidna to optimize a function
  - [How to detect high gas consumption](./finding-transactions-with-high-gas-consumption.md): How to find functions with high gas consumption.
  - [How to perform smart contract fuzzing at a large scale](./smart-contract-fuzzing-at-scale.md): How to use Echidna to run a long fuzzing campaign for complex smart contracts.
  - [How to test a library](https://blog.trailofbits.com/2020/08/17/using-echidna-to-test-a-smart-contract-library/): How Echidna was used to test the library in Set Protocol (blogpost)
  - [How to test bytecode-only contracts](./testing-bytecode.md): How to fuzz a contract without bytecode or to perform differential fuzzing between Solidity and Vyper
  - [How to use hevm cheats to test permit](./hevm-cheats-to-test-permit.md): How to test code that depends on ecrecover signatures using hevm cheat codes
  - [How to seed Echidna with unit tests](./end-to-end-testing.md): How to use existing unit tests to seed Echidna
  - [Understanding and using `multi-abi`](./using-multi-abi.md): What is `multi-abi` testing, and how can it be used
  - [Fuzzing tips](./fuzzing_tips.md): General fuzzing tips
- Exercises
  - [Exercise 1](./Exercise-1.md): Testing token balances
  - [Exercise 2](./Exercise-2.md): Testing access control
  - [Exercise 3](./Exercise-3.md): Testing with custom initialization
  - [Exercise 4](./Exercise-4.md): Testing with `assert`
  - [Exercise 5](./Exercise-5.md): Solving Damn Vulnerable DeFi - Naive Receiver
  - [Exercise 6](./Exercise-6.md): Solving Damn Vulnerable DeFi - Unstoppable
  - [Exercise 7](./Exercise-7.md): Solving Damn Vulnerable DeFi - Side Entrance
  - [Exercise 8](./Exercise-8.md): Solving Damn Vulnerable DeFi - The Rewarder

Join the team on Slack at: https://empireslacking.herokuapp.com/ #ethereum

## Installation

Echidna can be installed through docker or using the pre-compiled binary.

### MacOS

You can install Echidna with `brew install echidna`. 

### Echidna through docker

```bash
docker pull trailofbits/eth-security-toolbox
docker run -it -v "$PWD":/home/training trailofbits/eth-security-toolbox
```

*The last command runs eth-security-toolbox in a docker container that has access to your current directory. You can change the files from your host and run the tools on the files through the container*

Inside docker, run :

```bash
solc-select use 0.5.11
cd /home/training
```

### Binary

Check for the lastest released binary here:

[https://github.com/crytic/echidna/releases/latest](https://github.com/crytic/echidna/releases/latest)

The solc version is important to ensure that these exercises work as expected, we tested them using version 0.5.11.
