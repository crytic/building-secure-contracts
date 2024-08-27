# Introduction to Property-Based Fuzzing

Echidna is a property-based fuzzer, which we have described in our previous blog posts ([1](https://blog.trailofbits.com/2018/03/09/echidna-a-smart-fuzzer-for-ethereum/), [2](https://blog.trailofbits.com/2018/05/03/state-machine-testing-with-echidna/), [3](https://blog.trailofbits.com/2020/03/30/an-echidna-for-all-seasons/)).

## Fuzzing

Fuzzing is a well-known technique in the security community. It involves generating more or less random inputs to find bugs in a program. Fuzzers for traditional software (such as [AFL](http://lcamtuf.coredump.cx/afl/) or [LibFuzzer](https://llvm.org/docs/LibFuzzer.html)) are known to be efficient tools for bug discovery.

Beyond purely random input generation, there are many techniques and strategies used for generating good inputs, including:

- **Obtaining feedback from each execution and guiding input generation with it**. For example, if a newly generated input leads to the discovery of a new path, it makes sense to generate new inputs closer to it.
- **Generating input with respect to a structural constraint**. For instance, if your input contains a header with a checksum, it makes sense to let the fuzzer generate input that validates the checksum.
- **Using known inputs to generate new inputs**. If you have access to a large dataset of valid input, your fuzzer can generate new inputs from them, rather than starting from scratch for each generation. These are usually called _seeds_.

## Property-Based Fuzzing

Echidna belongs to a specific family of fuzzers: property-based fuzzing, which is heavily inspired by [QuickCheck](https://en.wikipedia.org/wiki/QuickCheck). In contrast to a classic fuzzer that tries to find crashes, Echidna aims to break user-defined invariants.

In smart contracts, invariants are Solidity functions that can represent any incorrect or invalid state that the contract can reach, including:

- Incorrect access control: The attacker becomes the owner of the contract.
- Incorrect state machine: Tokens can be transferred while the contract is paused.
- Incorrect arithmetic: The user can underflow their balance and get unlimited free tokens.
