# Bad Randomness

Pseudorandom number generation on the blockchain is generally unsafe. There are a number of reasons for this, including:

- The blockchain does not provide any cryptographically secure source of randomness. Block hashes in isolation are cryptographically random, however, a malicious miner can modify block headers, introduce additional transactions, and choose not to publish blocks in order to influence the resulting hashes. Therefore, miner-influenced values like block hashes and timestamps should never be used as a source of randomness.

- Everything in a contract is publicly visible. Random numbers cannot be generated or stored in the contract until after all lottery entries have been stored.

- Computers will always be faster than the blockchain. Any number that the contract could generate can potentially be precalculated off-chain before the end of the block.

A common workaround for the lack of on-chain randomness is using a commit and reveal scheme. Here, each user submits the hash of their secret number.
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

- [Verifiable delay functions](https://eprint.iacr.org/2018/601.pdf): functions which produce a pseudorandom number
and take a fixed amount of sequential time to evaluate
- [Randao](https://github.com/randao/randao): A commit reveal scheme where users must stake wei to participate

## Examples

- The `random` function in [theRun](theRun_source_code/theRun.sol) was vulnerable to this attack. It used the blockhash, timestamp and block number to generate numbers in a range to determine winners of the lottery. To exploit this, an attacker could set up a smart contract that generates numbers in the same way and submits entries when it would win. As well, the miner of the block has some control over the blockhash and timestamp and would also be able to influence the lottery in their favor.

## Sources

- https://ethereum.stackexchange.com/questions/191/how-can-i-securely-generate-a-random-number-in-my-smart-contract
- https://blog.positive.com/predicting-random-numbers-in-ethereum-smart-contracts-e5358c6b8620
