# Race Condition

## Principle
- There is a gap between the creation of a transaction and the moment it is accepted in the blockchain
- An attacker can take advantage of this gap to put a contract in an unexpected state for a target

## Example
- Bob creates `RaceCondition(100, token)`
- Alice trusts `RaceCondition` with all its tokens
- Alice calls `buy(150)`
- Bob sees the transaction, and calls `changePrice(300)` 
- The transaction of Bob is mined before the one of Alice

As a result, Bob received 300 tokens.

## Known exploit
ERC20 approve/transferFrom
