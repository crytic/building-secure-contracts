# Understanding and using `multi-abi` in Echidna

**Table of contents:**

- [Understanding and using `multi-abi` in Echidna](#understanding-and-using-multi-abi-in-echidna)
  - [Introduction](#introduction)
  - [What is `multi-abi` testing?](#what-is-multi-abi-testing)
  - [When and how to use `multi-abi`](#when-and-how-to-use-multi-abi)
  - [Run Echidna](#run-echidna)
    - [Example run with `multi-abi` set to `false`](#example-run-with-multi-abi-set-to-false)
    - [Example run with `multi-abi` set to `true`](#example-run-with-multi-abi-set-to-true)
  - [Use cases and conclusions](#use-cases-and-conclusions)

## Introduction

This tutorial is a hands-on guide to using `multi-abi` testing in Echidna. You'll learn what `multi-abi` testing is, how to use it in your tests, and what to expect from its usage.

## What is `multi-abi` testing?

`Multi-abi` testing is a mode that allows Echidna to call functions from any contract not directly under test. The ABI for the contract must be known, and it must have been deployed by the contract under test.

## When and how to use `multi-abi`

By default, Echidna calls functions from the contract to be analyzed, sending transactions randomly from addresses `0x10000`, `0x20000`, and `0x30000`.

In some systems, the user has to interact with other contracts before calling a function on the fuzzed contract. A common example is when you want to provide liquidity to a DeFi protocol; you'll first need to approve the protocol for spending your tokens. This transaction has to be initiated from your account before actually interacting with the protocol contract.

A fuzzing campaign meant to test this example protocol contract won't be able to modify user allowances. Therefore, most interactions with the protocol won't be tested correctly.

This is where `multi-abi` testing comes in handy: It allows Echidna to call functions from other contracts (not just from the contract under test), sending transactions from the same accounts that will interact with the target contract.

## Run Echidna

We'll use a simple example to demonstrate how `multi-abi` works. We'll be using two contracts, `Flag` and `EchidnaTest`, both available in [multiabi.sol](https://github.com/crytic/building-secure-contracts/blob/master/program-analysis/echidna/example/multiabi.sol).

The `Flag` contract contains a boolean flag that is only set if `flip()` is called, and a getter function returns the value of the flag. For now, ignore `test_fail()`; we'll discuss this function later.

```solidity
contract Flag {
    bool flag = false;

    function flip() public {
        flag = !flag;
    }

    function get() public returns (bool) {
        return flag;
    }

    function test_fail() public {
        assert(false);
    }
}
```

The test harness will instantiate a new `Flag`, and the invariant under test will be that `f.get()` (that is, the boolean value of the flag) is always false.

```solidity
contract EchidnaTest {
    Flag f;

    constructor() {
        f = new Flag();
    }

    function test_flag_is_false() public {
        assert(f.get() == false);
    }
}
```

In a non-`multi-abi` fuzzing campaign, Echidna is not able to break the invariant because it only interacts with `EchidnaTest` functions. However, if we use the following configuration file, enabling `multi-abi` testing, the invariant is broken. You can access [multiabi.yaml here](https://github.com/crytic/building-secure-contracts/blob/master/program-analysis/echidna/example/multiabi.yaml).

```yaml
testMode: assertion
testLimit: 50000
multi-abi: true
```

To run the Echidna tests, run `echidna multiabi.sol --contract EchidnaTest --config multiabi.yaml` from the `example` directory. Alternatively, you can specify `--multi-abi` in the command line instead of using a configuration file.

### Example run with `multi-abi` set to `false`

```
echidna multiabi.sol --contract EchidnaTest --config multiabi.yaml
Analyzing contract: building-secure-contracts/program-analysis/echidna/example/multiabi.sol:EchidnaTest
test_flag_is_false():  passed! 🎉
AssertionFailed(..):  passed! 🎉

Unique instructions: 282
Unique codehashes: 2
Corpus size: 2
Seed: -8252538430849362039
```

### Example run with `multi-abi` set to `true`

```
echidna multiabi.sol --contract EchidnaTest --config multiabi.yaml
Analyzing contract: building-secure-contracts/program-analysis/echidna/example/multiabi.sol:EchidnaTest
test_flag_is_false(): failed!💥
  Call sequence:
    flip()
    flip()
    flip()
    test_flag_is_false()

Event sequence: Panic(1)
AssertionFailed(..):  passed! 🎉

Unique instructions: 368
Unique codehashes: 2
Corpus size: 6
Seed: -6168343983565830424
```

## Use cases and conclusions

Testing with `multi-abi` is useful for complex systems that require the user to interact with more than one contract, as mentioned earlier. Another use case is for deployed contracts that require interactions to be initiated by specific addresses; for those specifying the `sender` configuration setting allows sending transactions from the correct account.

A side effect of using `multi-abi` is that the search space grows with the number of functions that can be called. This, combined with high values of sequence lengths, can make the fuzzing test less thorough because the size of the search space is simply too large to explore reasonably. Additionally, adding more functions as fuzzing candidates makes campaigns take up more execution time.

One final note is that `multi-abi` testing in assertion mode ignores all assert failures from contracts not under test. This is evident in the `Flag.test_fail()` function: even though it explicitly asserts false, the Echidna test ignores it.
