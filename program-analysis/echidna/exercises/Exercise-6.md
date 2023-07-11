# Exercise 6

**Table of Contents:**

- [Exercise 6](#exercise-6)
  - [Setup](#setup)
  - [Context](#context)
  - [Goals](#goals)
  - [Hints](#hints)
  - [Solution](#solution)

Join the team on Slack at: https://slack.empirehacking.nyc/ #ethereum

## Setup

1. Clone the repository: `git clone https://github.com/crytic/damn-vulnerable-defi-echidna`
2. Install the dependencies with `yarn install`.

## Context

The challenge is described here: https://www.damnvulnerabledefi.xyz/challenges/1.html. We assume that the reader is familiar with it.

## Goals

- Set up the testing environment with the appropriate contracts and necessary balances.
- Analyze the "before" function in `test/unstoppable/unstoppable.challenge.js` to identify the initial setup required.
- Add a property to check whether `UnstoppableLender` can always provide flash loans.
- Create a `config.yaml` file with the required configuration option(s).
- Once Echidna finds the bug, fix the issue, and retry your property with Echidna.

Only the following contracts are relevant:

- `contracts/DamnValuableToken.sol`
- `contracts/unstoppable/UnstoppableLender.sol`
- `contracts/unstoppable/ReceiverUnstoppable.sol`

## Hints

We recommend trying without reading the following hints first. The hints are in the [`hints` branch](https://github.com/crytic/damn-vulnerable-defi-echidna/tree/hints).

- The invariant we are looking for is "Flash loans can always be made".
- Read what the [allContracts option](../basic/common-testing-approaches.md#external-testing) is.
- The `receiveTokens` callback function must be implemented.
- A template is provided in [contracts/unstoppable/UnstoppableEchidna.sol](https://github.com/crytic/damn-vulnerable-defi-echidna/blob/hints/contracts/unstoppable/UnstoppableEchidna.sol).
- A configuration file is provided in [unstoppable.yaml](https://github.com/crytic/damn-vulnerable-defi-echidna/blob/hints/unstoppable.yaml).

## Solution

This solution can be found in the [`solutions` branch](https://github.com/crytic/damn-vulnerable-defi-echidna/blob/solutions/contracts/unstoppable/UnstoppableEchidna.sol).

[ctf]: https://www.damnvulnerabledefi.xyz/

<details>
<summary>Solution Explained (spoilers ahead)</summary>

Note: Please ensure that you have placed `solution.sol` (or `UnstoppableEchidna.sol`) in `contracts/unstoppable`.

The goal of the unstoppable challenge is to recognize that `UnstoppableLender` has two modes of tracking its balance: `poolBalance` and `damnValuableToken.balanceOf(address(this))`.

`poolBalance` is increased when someone calls `depositTokens()`.

However, a user can call `damnValuableToken.transfer()` directly and increase the `balanceOf(address(this))` without increasing `poolBalance`.

Now, the two balance trackers are out of sync.

When Echidna calls `pool.flashLoan(10)`, the assertion `assert(poolBalance == balanceBefore)` in `UnstoppableLender` will fail, and the pool can no longer provide flash loans.

See the example output below from Echidna:

```bash
echidna . --contract UnstoppableEchidna --config unstoppable.yaml

...

echidna_testFlashLoan: failed!💥
  Call sequence:
    transfer(0x62d69f6867a0a084c6d313943dc22023bc263691,1296000)

...
```

</details>
