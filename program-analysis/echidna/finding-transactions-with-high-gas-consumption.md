# Finding transactions with high gas consumption

**Table of contents:**

- [Introduction](#introduction)
- [Measuring Gas Consumption](#measuring-gas-consumption)
- [Run Echidna](#run-echidna)
- [Filtering Out Gas-Reducing Calls](#filtering-out-gas-reducing-calls)
- [Summary: Finding transactions with high gas consumption](#summary-finding-transactions-with-high-gas-consumption)

## Introduction

We will see how to find the transactions with has gas consumption with Echidna. The target is the following smart contract:

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
Here `expensive` can have a large gas consumption. 

Currently, Echidna always need a property to test: here `echidna_test` always returns `true`.
We can run Echidna to verify this:

```
$ echidna-test gas.sol
...
echidna_test: passed! 🎉

Seed: 2320549945714142710
```

## Measuring Gas Consumption

To enable the gas consumption with Echidna, create an configuration file `config.yaml`:

```yaml
estimateGas: true
```

In this example, we will also reduce the size of the transaction sequence to make the results easier to understand: 

```yaml
seqLen: 2
estimateGas: true
```

# Run Echidna

Once we have the configuration file created, we can run Echidna like this:

```
$ echidna-test gas.sol --config config.yaml 
...
echidna_test: passed! 🎉

f used a maximum of 1333608 gas
  Call sequence:
    f(42,123,249) Gas price: 0x10d5733f0a Time delay: 0x495e5 Block delay: 0x88b2

Unique instructions: 157
Unique codehashes: 1
Seed: -325611019680165325

```

- The gas shown is an estimation provided by [HEVM](https://github.com/dapphub/dapptools/tree/master/src/hevm#hevm-).

# Filtering Out Gas-Reducing Calls

The tutorial on [filtering functions to call during a fuzzing campaign](./filtering-functions.md) shows how to
remove some functions from your testing.  
This can be critical for getting an accurate gas estimate.
Consider the following example:

```solidity
contract C {
  address [] addrs;
  function push(address a) public {
    addrs.push(a);
  }
  function pop() public {
    addrs.pop();
  }
  function clear() public{
    addrs.length = 0;
  }
  function check() public{
    for(uint256 i = 0; i < addrs.length; i++)
      for(uint256 j = i+1; j < addrs.length; j++)
        if (addrs[i] == addrs[j])
          addrs[j] = address(0x0);
  }
  function echidna_test() public returns (bool) {
      return true;
  }
}
```
If Echidna can call all the functions, it won't easily find transactions with high gas cost:

```
$ echidna-test pushpop.sol --config config.yaml
...
pop used a maximum of 10746 gas
...
check used a maximum of 23730 gas
...
clear used a maximum of 35916 gas
...
push used a maximum of 40839 gas
```

That's because the cost depends on the size of `addrs` and random calls tend to leave the array almost empty.
Blacklisting `pop` and `clear`, however, gives us much better results:

```yaml
filterBlacklist: true
filterFunctions: ["C.pop()", "C.clear()"]
```

```
$ echidna-test pushpop.sol --config config.yaml
...
push used a maximum of 40839 gas
...
check used a maximum of 1484472 gas
```

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
