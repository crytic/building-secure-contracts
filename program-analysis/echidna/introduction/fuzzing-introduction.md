# Introduction to property-based fuzzing

Echidna is a property-based fuzzer, which we described in our previous blogposts ([1](https://blog.trailofbits.com/2018/03/09/echidna-a-smart-fuzzer-for-ethereum/), [2](https://blog.trailofbits.com/2018/05/03/state-machine-testing-with-echidna/), [3](https://blog.trailofbits.com/2020/03/30/an-echidna-for-all-seasons/)).

## Fuzzing

Fuzzing is a well-known technique in the security community. It consists of generating more or less random inputs to find bugs in the program. Fuzzers for traditional software (such as [AFL](http://lcamtuf.coredump.cx/afl/) or [LibFuzzer](https://llvm.org/docs/LibFuzzer.html)) are known to be efficient tools to find bugs.

Beyond the purely random generation of inputs, there are many techniques and strategies to generate good inputs, including:

- **Obtain feedback from each execution and guide generation using it**. For example, if a newly generated input leads to the discovery of a new path, it makes sense to generate new inputs closest to it.
- **Generate input with respect to a structural constraint**. For example, if your input contains a header with a checksum, it makes sense to let the fuzzer generate input validating the checksum.
- **Use known inputs to generate new inputs**. If you have access to a large dataset of valid input, your fuzzer can generate new inputs from them, rather than starting from scratch for each generation. These are usually called _seeds_.

## Property-based fuzzing

Echidna belongs to a specific family of fuzzer: property-based fuzzing heavily inspired by [QuickCheck](https://en.wikipedia.org/wiki/QuickCheck). In contrast to a classic fuzzer that will try to find crashes, Echidna will try to break user-defined invariants.

In smart contracts, invariants are Solidity functions that can represent any incorrect or invalid state that the contract can reach, including:

- Incorrect access control: the attacker became the owner of the contract.
- Incorrect state machine: the tokens can be transferred while the contract is paused.
- Incorrect arithmetic: the user can underflow its balance and get unlimited free tokens.
