# Example: Arithmetic Overflow

This scenario is provided as an example. You can use its structure as a guide to solving the exercises.

[`my_token.py`](example/my_token.py) utilizes Manticore to discover if an attacker can generate tokens during a transfer on the Token contract ([my_token.sol](example/my_token.sol)).

## Proposed Scenario

We will use the pattern of initialization, exploration, and property checking for our scripts.

## Initialization

- Create one user account
- Create the contract account

## Exploration

- Call 'balances' on the user account
- Call 'transfer' with a symbolic destination and value
- Call 'balances' on the user account again

## Property Checking

- Verify if the user can possess more tokens after the transfer than before.
