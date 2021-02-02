# Filtering functions to call during a fuzzing campaign

**Table of contents:**

- [Introduction](#introduction)
- [Filtering functions](#filtering-functions)
- [Run Echidna](#run-echidna)
- [Summary: Filtering functions](#summary-filtering-functions)

## Introduction

We will see how to filter the functions to be fuzzed.
The target is the following smart contract: 

```solidity
contract C {
  bool state1 = false;
  bool state2 = false;
  bool state3 = false;
  bool state4 = false;

  function f(uint x) public {
    require(x == 12);
    state1 = true;
  }

  function g(uint x) public {
    require(state1);
    require(x == 8);
    state2 = true;
  }

  function h(uint x) public {
    require(state2);
    require(x == 42);
    state3 = true;
  }

 function i() public {
    require(state3);
    state4 = true;
  }

  function reset1() public {
    state1 = false;
    state2 = false;
    state3 = false;
    return;
  }

  function reset2() public {
    state1 = false;
    state2 = false;
    state3 = false;
    return;
  }

  function echidna_state4() public returns (bool) {
    return (!state4);
  }

}
```

This small example forces Echidna to find a certain sequence of transactions to change a state variable. 
This is hard for a fuzzer (it is recommended to use a symbolic execution tool like [Manticore](https://github.com/trailofbits/manticore)).
We can run Echidna to verify this:

```
$ echidna-test multi.sol 
...
echidna_state4: passed! 🎉
Seed: -3684648582249875403
```

## Filtering functions

Echidna has trouble finding the correct sequence to test this contract because the two reset functions (`reset1` and `reset2`) will set all the state variables to `false`. 
However, we can use a special Echidna feature to either blacklist the reset function or to whitelist only the `f`, `g`, 
`h` and `i` functions. 

To blacklist functions, we can use this configuration file:

```yaml
filterBlacklist: true
filterFunctions: ["C.reset1()", "C.reset2()"]
```

Another approach to filter functions is to list the whitelisted functions. To do that, we can use this configuration file:

```yaml
filterBlacklist: false
filterFunctions: ["C.f(uint256)", "C.g(uint256)", "C.h(uint256)", "C.i()"]
```

- `filterBlacklist` is `true` by default.
- Filtering will be performed by full function name (contract name + "." + ABI). If you have `f()` and `f(uint256)`, you can specify exactly which function to filter.

# Run Echidna

To run Echidna with a configuration file `blacklist.yaml`:

```
$ echidna-test multi.sol --config blacklist.yaml 
...
echidna_state4: failed!💥  
  Call sequence:
    f(12)
    g(8)
    h(42)
    i()
```

Echidna will find the sequence of transactions to falsify the property almost inmmediately. 


## Summary: Filtering functions

Echidna can either blacklist or whitelist functions to call during a fuzzing campaign using:

```yaml
filterBlacklist: true
filterFunctions: ["C.f1()", "C.f2()", "C.f3()"]
```

```bash
$ echidna-test contract.sol --config config.yaml 
...
```

Echidna starts a fuzzing campaign either blacklisting `C.f1()`, `C.f2()` and `C.f3()` or only calling these, according
to the value of the `filterBlacklist` boolean.
