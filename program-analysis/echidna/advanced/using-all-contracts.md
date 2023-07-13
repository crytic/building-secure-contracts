# Understanding and using `allContracts` in Echidna

**Table of contents:**

- [Understanding and using `allContracts` in Echidna](#understanding-and-using-allContracts-in-echidna)
  - [Introduction](#introduction)
  - [What is `allContracts` testing?](#what-is-allContracts-testing)
  - [When and how to use `allContracts`](#when-and-how-to-use-allContracts)
  - [Run Echidna](#run-echidna)
    - [Example run with `allContracts` set to `false`](#example-run-with-allContracts-set-to-false)
    - [Example run with `allContracts` set to `true`](#example-run-with-allContracts-set-to-true)
  - [Use cases and conclusions](#use-cases-and-conclusions)

## Introduction

This tutorial is written as a hands-on guide to using `allContracts` testing in Echidna. You will learn what `allContracts` testing is, how to use it in your tests, and what to expect from its usage.

> This feature used to be called `multi-abi` but it was later renamed to `allContracts` in Echidna 2.1.0. As expected, this version or later is required for this tutorial.

## What is `allContracts` testing?

It is a testing mode that allows Echidna to call functions from any contract not directly under test. The ABI for the contract must be known, and it must have been deployed by the contract under test.

## When and how to use `allContracts`

By default, Echidna calls functions from the contract to be analyzed, sending the transactions randomly from addresses `0x10000`, `0x20000` and `0x30000`.

In some systems, the user has to interact with other contracts prior to calling a function on the fuzzed contract. A common example is when you want to provide liquidity to a DeFi protocol, you will first need to approve the protocol for spending your tokens. This transaction has to be initiated from your account before actually interacting with the protocol contract.

A fuzzing campaign meant to test this example protocol contract won't be able to modify users allowances, therefore most of the interactions with the protocol won't be tested correctly.

This is where `allContracts` testing is useful: It allows Echidna to call functions from other contracts (not just from the contract under test), sending the transactions from the same accounts that will interact with the target contract.

## Run Echidna

We will use a simple example to show how `allContracts` works. We will be using two contracts, `Flag` and `EchidnaTest`, both available in [allContracts.sol](../example/allContracts.sol).

The `Flag` contract contains a boolean flag that is only set if `flip()` is called, and a getter function that returns the value of the flag. For now, ignore `test_fail()`, we will talk about this function later.

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

In a non `allContracts` fuzzing campaign, Echidna is not able to break the invariant, because it only interacts with `EchidnaTest` functions. However, if we use the following configuration file, enabling `allContracts` testing, the invariant is broken. You can access [allContracts.yaml here](../example/allContracts.yaml).

```yaml
testMode: assertion
testLimit: 50000
allContracts: true
```

To run the Echidna tests, run `echidna allContracts.sol --contract EchidnaTest --config allContracts.yaml` from the `example` directory. Alternatively, you can specify `--all-contracts` in the command line instead of using a configuration file.

### Example run with `allContracts` set to `false`

```
echidna allContracts.sol --contract EchidnaTest --config allContracts.yaml
Analyzing contract: building-secure-contracts/program-analysis/echidna/example/allContracts.sol:EchidnaTest
test_flag_is_false():  passed! 🎉
AssertionFailed(..):  passed! 🎉

Unique instructions: 282
Unique codehashes: 2
Corpus size: 2
Seed: -8252538430849362039
```

### Example run with `allContracts` set to `true`

```
echidna allContracts.sol --contract EchidnaTest --config allContracts.yaml
Analyzing contract: building-secure-contracts/program-analysis/echidna/example/allContracts.sol:EchidnaTest
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

Testing with `allContracts` is a useful tool for complex systems that require the user to interact with more than one contract, as we mentioned earlier. Another use case is for deployed contracts that require interactions to be initiated by specific addresses: for those, specifying the `sender` configuration setting allows to send the transactions from the correct account.

A side-effect of using `allContracts` is that the search space grows with the number of functions that can be called. This, combined with high values of sequence lengths, can make the fuzzing test not so thorough, because the dimension of the search space is simply too big to reasonably explore. Finally, adding more functions as fuzzing candidates makes the campaigns to take up more execution time.

A final remark is that `allContracts` testing in assertion mode ignores all assert failures from the contracts not under test. This is shown in `Flag.test_fail()` function: even though it explicitly asserts false, the Echidna test ignores it.
