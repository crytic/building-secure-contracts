
# Exercice 1 : Arithmetic

Use Manticore to find an input allowing an attacker to generate free tokens in [exercise1/token.sol](./exercise1/token.sol).
Propose a fix of the contract, and test your fix using your Manticore script.

## Proposed scenario

Follow the pattern initilization, exploration and property for the script.

### Initialization

- Create one account
- Create the contract account

### Exploration

- Call `is_valid_buy` with two symbolic values for tokens_amount and wei_amount

### Property

- An attack is found if on a state alive `wei_amount == 0 and tokens_amount >= 1`

### Hints

- `m.ready_states` returns the list of state alive
- `Operators.AND(a, b)` allows to create and AND condition
- You can use the template proposed in [exercise1/template.sol](./exercise1/template.sol)

### Solution

[exercise1/solution.py](./exercise1/solution.py)