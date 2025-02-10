# Exercise 1: Arithmetic Rounding

Use Manticore to discover an input that allows an attacker to generate free tokens in [token.sol](https://github.com/crytic/building-secure-contracts/tree/master/program-analysis/manticore/exercises/exercise1/token.sol). Propose a fix for the contract and test your solution using the Manticore script.

## Proposed Scenario

Follow the initialization, exploration, and property pattern for the script.

## Initialization

- Create one account
- Create the contract account

## Exploration

- Call `is_valid_buy` with two symbolic values for `tokens_amount` and `wei_amount`

## Property

- An attack is discovered if, on a live state, `wei_amount == 0 and tokens_amount >= 1`

## Hints

- `m.ready_states` returns a list of live states
- Use `Operators.AND(a, b)` to create an AND condition
- The [template.py](https://github.com/crytic/building-secure-contracts/tree/master/program-analysis/manticore/exercises/exercise1/template.py) can serve as a starting point

## Solution

Refer to [solution.py](https://github.com/crytic/building-secure-contracts/tree/master/program-analysis/manticore/exercises/exercise1/solution.py) for a possible solution.
