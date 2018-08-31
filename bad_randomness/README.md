# Bad Randomness

Due to the fact that all information on the blockchain in public, acquiring random numbers that cannot be influenced by malicious actors is nearly impossible.
(larger preamble)

People have mistakenly attempted to use the following sources of "randomness" in their smart contracts

- Past, present, or future block hash
- Block difficulty
- Timestamp
- etc

The problem with each of these examples is that miners can influence their values. Even if it is unlikely a miner is able to specify exactly what these variables become,
they could stack the cards slightly in their favor. (reference specific examples).

A common workaround for this issue is a commit and reveal scheme. (discuss)

## Attacks

## Consequences

## Mitigations

There are currently not any recommended mitigations for this issue. Do not build applications that require on-chain randomness.
In the future, however, these approaches show promise

-- Verifiable delay functions: functions which produce a pseudorandom number and take a fixed amount of sequential time to evaluate
-- Randao:

## Real world examples