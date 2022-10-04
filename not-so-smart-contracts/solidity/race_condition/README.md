# Race Condition

There is a gap between the creation of a transaction and the moment it is accepted in the blockchain. Therefore, an attacker can take advantage of this gap to put a contract in a state that advantages them.

## Attack Scenario

- Bob creates `RaceCondition(100, token)`. Alice approves `RaceCondition` to spend all of her tokens. Alice calls `buy(150)` and Bob (or one of his bots) quickly sees the transaction and calls `changePrice(300)` with a high gas price. Bob's transaction is mined before Alice's and as a result, Bob received 300 tokens. See [the RaceCondition contract](RaceCondition.sol) for an example of this;

- The ERC20 standard's `approve` and `transferFrom` functions are vulnerable to a race condition. Suppose Alice has approved Bob to spend 100 tokens on her behalf. She then decides to only approve him for 50 tokens and sends a second `approve` transaction. However, Bob sees that he's about to be downgraded and quickly submits a `transferFrom` for the original 100 tokens he was approved for. If this transaction gets mined before Alice's second `approve`, Bob will be able to spend an additional 50 of Alice's tokens (for a total of 150) after her new `approve` transaction is mined.

## Mitigations

- For the ERC20 bug, insist that Alice only be able to `approve` Bob when he is approved for 0 tokens. Or, Alice can reset Bob's allowance to zero before resetting it to ensure that he can't spend any more than her current allowance.
- Keep in mind that all transactions may be front-run.
