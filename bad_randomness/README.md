# Bad Randomness

Due to the fact that all information on the blockchain in public, acquiring random numbers that
cannot be influenced by malicious actors is nearly impossible.

People have mistakenly attempted to use the following sources of "randomness" in their smart contracts

- Block variables such as `coinbase`, `difficulty`, `gasLimit`, `number`, and `timestamp`
- Blockhash of a past or future block

The problem with each of these examples is that miners can influence their values.
Even if it is unlikely a miner is able to specify exactly what these quantities,
they could stack the cards slightly in their favor.

A common workaround for this issue is a commit and reveal scheme. Here, each user submits the hash of their secret number.
When the time comes for the random number to be generated, each user sends their secret number to the contract
which then verifies it matches the hash submitted earlier and xors them together. Therefore no participant can observe how their contribution
will affect the end result until after everyone has already committed to a value. However, this is also vulnerable to DoS attacks,
since the last person to reveal can choose to never submit their secret. Even if the contract is allowed to move forward without
everyone's secrets, this gives them influence over the end result. In general, we do not recommend commit and reveal schemes.

## Attack Scenarios

- A lottery where people bet on whether the hash of the current block is even or odd. A miner that bets on even can throw out blocks whose
hash are even.
- A commit-reveal scheme where users don't necessarily have to reveal their secret (to prevent DoS). A user has money riding on the outcome
of the PRG and submits a large number of commits, allowing them to choose the one they want to reveal at the end.

## Mitigations

There are currently not any recommended mitigations for this issue.
Do not build applications that require on-chain randomness.
In the future, however, these approaches show promise

- Verifiable delay functions: functions which produce a pseudorandom number
and take a fixed amount of sequential time to evaluate
- Randao: A commit reveal scheme where users must stake wei to participate

## Examples

## Sources

- https://ethereum.stackexchange.com/questions/191/how-can-i-securely-generate-a-random-number-in-my-smart-contract
- https://blog.positive.com/predicting-random-numbers-in-ethereum-smart-contracts-e5358c6b8620
- Forthcoming VDF blog post.
- https://github.com/randao/randao