# Exercise 2

This exercise is fairly more involved 
**Table of contents:**

- [Exercise 2](#exercise-2)
  - [Targeted contract](#targeted-contract)
  - [Testing](#testing)
    - [Goals](#goals)
  - [Solution](#solution)

Join the team on Slack at: https://empireslacking.herokuapp.com/ #ethereum

## Targeted contract

We will test the following contract the [LiquidityTracker](./exercise2/LiquidityTracker.sol) contract.

This contract stores a Data struct, containing token balances for risky, stable, and liquidity amounts. 

```
    /// @notice                Stores global state of a pool
    /// @param reserveRisky    Risky token reserve
    /// @param reserveStable   Stable token reserve
    /// @param liquidity       Total supply of liquidity
    struct Data {
        uint128 reserveRisky;
        uint128 reserveStable;
        uint128 liquidity;
    }
```

All functions in the LiquidityTracker contract are used to adjust and change balances on the addition and removal of funds. 

## Testing 

### Goals
While writing invariants for this code, consider the following: 
- what is the expected behaviour of all the functions?
- what is expected behaviour across the system, considering functions holistically? 

## Solution

This solution can be found in [solution.sol](./exercise2/solution.sol).
