# Exercice 2: Access control

[exercises/exercise2/coin.sol](exercises/exercise2/coin.sol) possess an access control with the `onlyOwner` modifier.
A frequent mistake is to forget to add the modifier to a critical function. We are going to see how to implement a conservative access control approach with Slither.

The goal is to create a script that will ensure that all the public and external function calls `onlyOwner`, except for the functions whitelisted.

## Proposed algorithm

```
Create a whitelist of signatures
Explore all the functions
    If the function is in the whitelist of signatures:
        Skip
    If the function is public or external:
        If onlyOwner is not in the modifiers:
            A bug is found
```

## Solution

See [exercises/exercise2/solution.py](exercises/exercise2/solution.py).
