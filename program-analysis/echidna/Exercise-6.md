# Exercise 6

**Table of contents:**

- [Exercise 6](#exercise-6)
  - [Setup](#setup)
  - [Exercise](#exercise)
  - [Solution](#solution)

Join the team on Slack at: https://empireslacking.herokuapp.com/ #ethereum

## Setup

Note: All 6 of the following steps are analogous to [Exercise 5](./Exercise-5.md).

1. Follow the instructions on the [Damn Vulnerable DeFi CTF][ctf] page, namely:
  - clone the repo, and
  - install the dependencies.
2. Create a contract called `NaiveReceiverEchidna` in the `contract/naive-receiver` directory.
3. Write the initialization script into the constructor. This should be based on the `before` function in `test/naive-receiver/naive-receiver.challenge.js`.
- Hint: You don't need to make the setup very complex. It is possible to find the bug with just two contracts:
  - initialization contract and target contract of Echidna
  - NaiveReceiverLenderPool

## Exercise

4. Write possible entrypoints, callback functions, and/or properties. There should be a property that reflects the invariant we want to break (an address has its ether balance decrease).
5. Write an Echidna config file.
6. Run Echidna 🎉.
- Hint: Try using `multi-abi: true` in your config file.

## Solution

This solution can be found in [exercises/exercise6/solution.sol](./exercises/exercise6/solution.sol)

[ctf]: https://www.damnvulnerabledefi.xyz/