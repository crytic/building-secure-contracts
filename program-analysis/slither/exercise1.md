# Exercice 1 : Function overridden protection
The goal is to create a script that fills a missing feature of Solidity: function overriding protection.

[exercises/exercise1/coin.sol](exercises/exercise1/coin.sol) contains a function that must never be overridden:

```solidity
_mint(address dst, uint val)
```

Use Slither to ensure that no contract that inherits Coin overrides this function.

## Proposed algorithm

```
Get the coin contract
    For each contract of the project:
        If Coin is in the list of inherited contract:
            Get the mint function
            If the contract declaring the mint function is != Coin:
                A bug is found.
```

## Hints

- To get a specific contract, use `slither.get_contract_from_name` (note: it returns a list)
- To get a specific function, use `contract.get_function_from_signature`

## Solution

See [exercises/exercise1/solution.py](exercises/exercise1/solution.py).
