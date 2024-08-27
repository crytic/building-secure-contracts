# Exercise 8

**Table of Contents:**

- [Exercise 8](#exercise-8)
  - [Setup](#setup)
  - [Context](#context)
  - [Goals](#goals)
  - [Hints](#hints)
  - [Solution](#solution)

Join the team on Slack at: https://slack.empirehacking.nyc/ #ethereum

## Setup

1. Clone the repo: `git clone https://github.com/crytic/damn-vulnerable-defi-echidna`.
2. Install the dependencies via `yarn install`.

## Context

The challenge is described here: https://www.damnvulnerabledefi.xyz/challenges/5.html. We assume that the reader is familiar with it.

## Goals

- Set up the testing environment with the right contracts and necessary balances.
- Analyze the before function in `test/the-rewarder/the-rewarder.challenge.js` to identify what initial setup needs to be done.
- Add a property to check whether the attacker can get almost the entire reward (let us say more than 99 %) from the `TheRewarderPool` contract.
- Create a `config.yaml` with the necessary configuration option(s).
- Once Echidna finds the bug, you will need to apply a completely different reward logic to fix the issue, as the current solution is a rather naive implementation.

Only the following contracts are relevant:

- `contracts/the-rewarder/TheRewarderPool.sol`
- `contracts/the-rewarder/FlashLoanerPool.sol`

## Hints

We recommend trying without reading the following hints first. The hints are in the [`hints` branch](https://github.com/crytic/damn-vulnerable-defi-echidna/tree/hints).

- The invariant you are looking for is "an attacker cannot get almost the entire amount of rewards."
- Read about the [allContracts option](../basic/common-testing-approaches.md#external-testing).
- A config file is provided in [the-rewarder.yaml](https://github.com/crytic/damn-vulnerable-defi-echidna/blob/solutions/the-rewarder.yaml).

## Solution

This solution can be found in the [`solutions` branch](https://github.com/crytic/damn-vulnerable-defi-echidna/blob/solutions/contracts/the-rewarder/EchidnaRewarder.sol).

[ctf]: https://www.damnvulnerabledefi.xyz/

<details>
<summary>Solution Explained (spoilers ahead)</summary>

The goal of the rewarder challenge is to realize that an arbitrary user can request a flash loan from the `FlashLoanerPool` and borrow the entire amount of Damn Valuable Tokens (DVT) available. Next, this amount of DVT can be deposited into `TheRewarderPool`. By doing this, the user affects the total proportion of tokens deposited in `TheRewarderPool` (and thus gets most of the percentage of deposited assets in that particular time on their side). Furthermore, if the user schedules this at the right time (once `REWARDS_ROUND_MIN_DURATION` is reached), a snapshot of users' deposits is taken. The user then immediately repays the loan (i.e., in the same transaction) and receives almost the entire reward in return.
In fact, this can be done even if the arbitrary user has no DVT.

Echidna reveals this vulnerability by finding the right order of two functions: simply calling (1) `TheRewarderPool.deposit()` (with prior approval) and (2) `TheRewarderPool.withdraw()` with the max amount of DVT borrowed through the flash loan in both mentioned functions.

See the example output below from Echidna:

```bash
echidna . --contract EchidnaRewarder --config ./the-rewarder.yaml
...

testRewards(): failed!💥
  Call sequence:
    *wait* Time delay: 441523 seconds Block delay: 9454
    setEnableDeposit(true) from: 0x0000000000000000000000000000000000030000
    setEnableWithdrawal(true) from: 0x0000000000000000000000000000000000030000
    flashLoan(39652220640884191256808) from: 0x0000000000000000000000000000000000030000
    testRewards() from: 0x0000000000000000000000000000000000030000

...
```

</details>
