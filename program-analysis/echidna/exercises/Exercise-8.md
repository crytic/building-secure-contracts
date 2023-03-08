# Exercise 8

**Table of contents:**

- [Exercise 8](#exercise-8)
  - [Setup](#setup)
  - [Context](#context)
  - [Goals](#goals)
  - [Hints](#hints)
  - [Solution](#solution)

Join the team on Slack at: https://empireslacking.herokuapp.com/ #ethereum

## Setup

1. Clone the repo: `git clone https://github.com/crytic/damn-vulnerable-defi-echidna`
2. install the dependencies via `yarn install`.

## Context

The challenge is described here: https://www.damnvulnerabledefi.xyz/challenges/5.html, we assume that the reader is familiar with it.

## Goals

- Setup the testing environment with the right contracts and necessary balances.
- Analyze the before function in `test/the-rewarder/the-rewarder.challenge.js` to identify what initial setup needs to be done.
- Add a property to check whether the attacker can get almost whole reward (let us say more than 99 %) from the `TheRewarderPool` contract.
- Create a `config.yaml` with the necessary configuration option(s).
- Once Echidna finds the bug, .... well, this time to fix the issue would mean to apply completely different reward logic as in this particular solution is rather naive implementation.

Only the following contracts are relevant:

- `contracts/the-rewarder/TheRewarderPool.sol`
- `contracts/the-rewarder/FlashLoanerPool.sol`

## Hints

We recommend to first try without reading the following hints. The hints are in the [`hints` branch](https://github.com/crytic/damn-vulnerable-defi-echidna/tree/hints).

- The invariant that we are looking for is "an attacker cannot get almost whole amount of rewards"
- Read what is the [multi abi option](../basic/common-testing-approaches.md#external-testing)
- A config file is provided in [the-rewarder.yaml](https://github.com/crytic/damn-vulnerable-defi-echidna/blob/solutions/the-rewarder.yaml)

## Solution

This solution can be found in [`solutions` branch](https://github.com/crytic/damn-vulnerable-defi-echidna/blob/solutions/contracts/the-rewarder/EchidnaRewarder.sol).

[ctf]: https://www.damnvulnerabledefi.xyz/

<details>
<summary>Solution Explained (spoilers ahead)</summary>

The goal of the rewarder challenge is to realize that an arbitrary user can call request a flash loan from `FlashLoanerPool` and borrow the whole amount of Damn Valuable Tokens (DVT) available. Then this amount of DVT can deposit into `TheRewarderPool`. By doing this, the user affects total proportion of tokens deposited in the `TheRewarderPool` (and thus gets the most of the percentage of deposited asset in that particular time on his/her side). Furthermore, if the user schedules it in the right time (once the `REWARDS_ROUND_MIN_DURATION` is reached), snapshot of users deposits is taken, the user repay immediately the loan (i.e., in the same transaction) and gets almost whole reward in return.
In fact, this can be done even if the arbitrary user has no DVT.

Echidna reveals this vulnerability by finding the right order of two function, simply calling (1) `TheRewarderPool.deposit()` (with prior approval) and (2) `TheRewarderPool.withdraw()` with the max amount of DVT borrowed in flash loan in both functions mentioned.

See example output below from Echidna:

```bash
echidna-test . --contract EchidnaRewarder --config ./the-rewarder.yaml
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
