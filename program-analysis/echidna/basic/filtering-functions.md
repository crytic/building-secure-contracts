# Filtering Functions for Fuzzing Campaigns

**Table of contents:**

- [Filtering Functions for Fuzzing Campaigns](#filtering-functions-for-fuzzing-campaigns)
  - [Introduction](#introduction)
  - [Filtering functions](#filtering-functions)
- [Running Echidna](#running-echidna)
  - [Summary: Filtering functions](#summary-filtering-functions)

## Introduction

In this tutorial, we'll demonstrate how to filter specific functions to be fuzzed using Echidna. We'll use the following smart contract _[multi.sol](https://github.com/crytic/building-secure-contracts/blob/master/program-analysis/echidna/example/multi.sol)_ as our target:

```solidity
contract C {
    bool state1 = false;
    bool state2 = false;
    bool state3 = false;
    bool state4 = false;

    function f(uint256 x) public {
        require(x == 12);
        state1 = true;
    }

    function g(uint256 x) public {
        require(state1);
        require(x == 8);
        state2 = true;
    }

    function h(uint256 x) public {
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

The small contract above requires Echidna to find a specific sequence of transactions to modify a certain state variable, which is difficult for a fuzzer. It's recommended to use a symbolic execution tool like [Manticore](https://github.com/trailofbits/manticore) in such cases. Let's run Echidna to verify this:

```
echidna multi.sol
...
echidna_state4: passed! 🎉
Seed: -3684648582249875403
```

## Filtering Functions

Echidna has difficulty finding the correct sequence to test this contract because the two reset functions (`reset1` and `reset2`) revert all state variables to `false`. However, we can use a special Echidna feature to either blacklist the `reset` functions or whitelist only the `f`, `g`, `h`, and `i` functions.

To blacklist functions, we can use the following configuration file:

```yaml
filterBlacklist: true
filterFunctions: ["C.reset1()", "C.reset2()"]
```

Alternatively, we can whitelist specific functions by listing them in the configuration file:

```yaml
filterBlacklist: false
filterFunctions: ["C.f(uint256)", "C.g(uint256)", "C.h(uint256)", "C.i()"]
```

- `filterBlacklist` is `true` by default.
- Filtering will be performed based on the full function name (contract name + "." + ABI function signature). If you have `f()` and `f(uint256)`, you can specify exactly which function to filter.

# Running Echidna

To run Echidna with a configuration file `blacklist.yaml`:

```
echidna multi.sol --config blacklist.yaml
...
echidna_state4: failed!💥
  Call sequence:
    f(12)
    g(8)
    h(42)
    i()
```

Echidna will quickly discover the sequence of transactions required to falsify the property.

## Summary: Filtering Functions

Echidna can either blacklist or whitelist functions to call during a fuzzing campaign using:

```yaml
filterBlacklist: true
filterFunctions: ["C.f1()", "C.f2()", "C.f3()"]
```

```bash
echidna contract.sol --config config.yaml
...
```

Depending on the value of the `filterBlacklist` boolean, Echidna will start a fuzzing campaign by either blacklisting `C.f1()`, `C.f2()`, and `C.f3()` or by _only_ calling those functions.
