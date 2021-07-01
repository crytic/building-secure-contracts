# Exercise 5

**Table of contents:**

- [Exercise 5](#exercise-5)
  - [Setup](#setup)
  - [Exercise](#exercise)
  - [Solution](#solution)

Join the team on Slack at: https://empireslacking.herokuapp.com/ #ethereum

## Setup

1. Follow the instructions on the [Damn Vulnerable DeFi CTF][ctf] page, name:
  - clone the repo, and
  - install the dependencies.
2. Create a contract called `UnstoppableEchidna` in the `contract/unstoppable` directory.
3. Write the initialization script into the constructor. This should be based on the `before` function in `test/unstoppable/unstoppable.challenge.js`.
- Hint: You don't need to make the setup very complex. It is possible to find the bug with just three contracts:
  - initialization contract and target contract of Echidna
  - DamnValuableToken
  - UnstoppableLender

## Exercise

4. Write possible entrypoints, callback functions, and/or properties. There should be a property that reflects the invariant we want to break (an address is not able to take a flashloan).
5. Write an Echidna config file.
6. Run Echidna 🎉.
- Hint: Try using `multi-abi: true` in your config file.

## Solution

This solution can be found in [exercises/exercise5/solution.sol](./exercises/exercise5/solution.sol)

[ctf]: https://www.damnvulnerabledefi.xyz/