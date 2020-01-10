# Example: Arithmetic overflow
This scenario is given as an example. You can follow its structure to solve the exercises.

[`my_token.py`](example/my_token.py) uses manticore to find for an attacker to generate tokens during a transfer on Token ([my_token.sol](exercises/example/my_token.sol)).

## Proposed scenario

We use the pattern initilization, exploration and property for our scripts.

### Initialization

- Create one user account
- Create the contract account

### Exploration

- Call balances on the user account
- Call transfer with symbolic destination and value
- Call balances on the user account

### Property

- Check if the user can have more token after the transfer than before.
