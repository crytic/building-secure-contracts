# Race Condition
There is a gap between the creation of a transaction and the moment it is accepted in the blockchain.
Therefore, an attacker can take advantage of this gap to put a contract in a state that advantages them.

## Attack Scenario

- Bob creates `RaceCondition(100, token)`. Alice trusts `RaceCondition` with all its tokens. Alice calls `buy(150)`
Bob sees the transaction, and calls `changePrice(300)`. The transaction of Bob is mined before the one of Alice and
as a result, Bob received 300 tokens.

- The ERC20 standard's `approve` and `transferFrom` functions are vulnerable to a race condition. Suppose Alice has
approved Bob to spend 100 tokens on her behalf. She then decides to only approve him for 50 tokens and sends
a second `approve` transaction. However, Bob sees that he's about to be downgraded and quickly submits a
`transferFrom` for the original 100 tokens he was approved for. If this transaction gets mined before Alice's
second `approve`, Bob will be able to spend 150 of Alice's tokens.

## Mitigations

- For the ERC20 bug, insist that Alice only be able to `approve` Bob when he is approved for 0 tokens.
- Keep in mind that all transactions may be front-run

## Examples
- [Race condition](RaceCondition.sol) outlined in the first bullet point above
