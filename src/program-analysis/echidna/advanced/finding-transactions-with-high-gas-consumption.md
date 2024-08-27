# Identifying High Gas Consumption Transactions

**Table of contents:**

- [Identifying high gas consumption transactions](#identifying-high-gas-consumption-transactions)
  - [Introduction](#introduction)
  - [Measuring Gas Consumption](#measuring-gas-consumption)
- [Running Echidna](#running-echidna)
- [Excluding Gas-Reducing Calls](#excluding-gas-reducing-calls)
  - [Summary: Identifying high gas consumption transactions](#summary-identifying-high-gas-consumption-transactions)

## Introduction

This guide demonstrates how to identify transactions with high gas consumption using Echidna. The target is the following smart contract ([gas.sol](https://github.com/crytic/building-secure-contracts/blob/master/program-analysis/echidna/example/gas.sol)):

```solidity
contract C {
    uint256 state;

    function expensive(uint8 times) internal {
        for (uint8 i = 0; i < times; i++) {
            state = state + i;
        }
    }

    function f(uint256 x, uint256 y, uint8 times) public {
        if (x == 42 && y == 123) {
            expensive(times);
        } else {
            state = 0;
        }
    }

    function echidna_test() public returns (bool) {
        return true;
    }
}
```

The `expensive` function can have significant gas consumption.

Currently, Echidna always requires a property to test - in this case, `echidna_test` always returns `true`.
We can run Echidna to verify this:

```
echidna gas.sol
...
echidna_test: passed! 🎉

Seed: 2320549945714142710
```

## Measuring Gas Consumption

To enable Echidna's gas consumption feature, create a configuration file [gas.yaml](https://github.com/crytic/building-secure-contracts/blob/master/program-analysis/echidna/example/gas.yaml):

```yaml
estimateGas: true
```

In this example, we'll also reduce the size of the transaction sequence for easier interpretation:

```yaml
seqLen: 2
estimateGas: true
```

# Running Echidna

With the configuration file created, we can run Echidna as follows:

```
echidna gas.sol --config config.yaml
...
echidna_test: passed! 🎉

f used a maximum of 1333608 gas
  Call sequence:
    f(42,123,249) Gas price: 0x10d5733f0a Time delay: 0x495e5 Block delay: 0x88b2

Unique instructions: 157
Unique codehashes: 1
Seed: -325611019680165325
```

- The displayed gas is an estimation provided by [HEVM](https://github.com/dapphub/dapptools/tree/master/src/hevm#hevm-).

# Excluding Gas-Reducing Calls

The tutorial on [filtering functions to call during a fuzzing campaign](../basic/filtering-functions.md) demonstrates how to remove certain functions during testing.
This can be crucial for obtaining accurate gas estimates.
Consider the following example ([example/pushpop.sol](https://github.com/crytic/building-secure-contracts/blob/master/program-analysis/echidna/example/pushpop.sol)):

```solidity
contract C {
    address[] addrs;

    function push(address a) public {
        addrs.push(a);
    }

    function pop() public {
        addrs.pop();
    }

    function clear() public {
        addrs.length = 0;
    }

    function check() public {
        for (uint256 i = 0; i < addrs.length; i++)
            for (uint256 j = i + 1; j < addrs.length; j++) if (addrs[i] == addrs[j]) addrs[j] = address(0);
    }

    function echidna_test() public returns (bool) {
        return true;
    }
}
```

With this [`config.yaml`](https://github.com/crytic/building-secure-contracts/blob/master/program-analysis/echidna/example/pushpop.yaml), Echidna can call all functions but won't easily identify transactions with high gas consumption:

```
echidna pushpop.sol --config config.yaml
...
pop used a maximum of 10746 gas
...
check used a maximum of 23730 gas
...
clear used a maximum of 35916 gas
...
push used a maximum of 40839 gas
```

This occurs because the cost depends on the size of `addrs`, and random calls tend to leave the array almost empty.
By blacklisting `pop` and `clear`, we obtain better results ([blacklistpushpop.yaml](https://github.com/crytic/building-secure-contracts/blob/master/program-analysis/echidna/example/blacklistpushpop.yaml)):

```yaml
estimateGas: true
filterBlacklist: true
filterFunctions: ["C.pop()", "C.clear()"]
```

```
echidna pushpop.sol --config config.yaml
...
push used a maximum of 40839 gas
...
check used a maximum of 1484472 gas
```

## Summary: Identifying high gas consumption transactions

Echidna can identify transactions with high gas consumption using the `estimateGas` configuration option:

```yaml
estimateGas: true
```

```bash
echidna contract.sol --config config.yaml
...
```

After completing the fuzzing campaign, Echidna will report a sequence with the maximum gas consumption for each function.
