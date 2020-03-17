# Finding transactions with high gas consumption

**Table of contents:**

- [Introduction](#introduction)
- [Measuring Gas Consumption](#measuring-gas-consumption)
- [Run Echidna](#run-echidna)
- [Summary: Finding transactions with high gas consumption](#summary-finding-transactions-with-high-gas-consumption)

## Introduction

In this short tutorial, we are going to show how to tell Echidna find transactions with high gas consumption. 
This feature can be useful to optimize contracts before deployment. Let's suppose we have a contract like this one: 

```solidity
contract C {
  uint state;

  function expensive(uint8 times) internal {
    for(uint8 i=0; i < times; i++)
      state = state + i;
  }

  function f(uint x, uint y, uint8 times) public {
    if (x == 42 && y == 123)
      expensive(times);
    else
      state = 0;
  }

  function echidna_test() public returns (bool) {
    return true;
  }

}
```

This small example shows a contract with a function that has a large gas consumption if certain input is provided. 
The echidna property to test is not important, so we just use one that always returns `true`.
We can run Echidna to verify this:

```
$ echidna-test gas.sol
...
echidna_test: passed! 🎉

Seed: 2320549945714142710
```

## Measuring Gas Consumption

Echidna can be used to detect transactions with high gas consumption using the `gasEstimate` configuratation options like this:

```yaml
estimateGas: true
```

In this example, we will also reduce the size of the transaction sequence to get results easier to understand: 

```yaml
seqLen: 2
estimateGas: true
```

# Run Echidna

Once we have the configuration file created, we can run Echidna like this:

```
$ echidna-test gas.sol --config gas.yaml 
...
echidna_test: passed! 🎉

f used a maximum of 1333608 gas
  Call sequence:
    f(42,123,249) Gas price: 0x10d5733f0a Time delay: 0x495e5 Block delay: 0x88b2

Unique instructions: 157
Unique codehashes: 1
Seed: -325611019680165325

```

It is important to note that the gas showed here is only an estimation provided by [HEVM](https://github.com/dapphub/dapptools/tree/master/src/hevm#hevm-). 
This should precise enough, but it can be slightly different from mainstream Ethereum clients.

## Summary: Finding transactions with high gas consumption

Echidna can find transactions with high gas consumption using the `estimateGas` configuration option:

```yaml
estimateGas: true
```

```bash
$ echidna-test contract.sol --config config.yaml 
...
```

Echidna will report a sequence with the maximum gas consumption for every function, once the fuzzing campaign is over.
