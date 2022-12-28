# Exercise 6

**Table of contents:**

- [Exercise 6](#exercise-6)
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

The challenge is described here: https://www.damnvulnerabledefi.xyz/challenges/1.html, we assume that the reader is familiar with it.

## Goals

- Setup the testing environment with the right contracts and necessary balances.
- Analyze the before function in test/unstoppable/unstoppable.challenge.js to identify what initial setup needs to be done.
- Add a property to check whether `UnstoppableLender` can always provide flash loans.
- Create a `config.yaml` with the necessary configuration option(s).
- Once Echidna finds the bug, fix the issue, and re-try your property with Echidna.

Only the following contracts are relevant:
  - `contracts/DamnValuableToken.sol`
  - `contracts/unstoppable/UnstoppableLender.sol`
  - `contracts/unstoppable/ReceiverUnstoppable.sol`

## Hints

We recommend to first try without reading the following hints. The hints are in the [`hints` branch](https://github.com/crytic/damn-vulnerable-defi-echidna/tree/hints).

- The invariant that we are looking for is "Flash loan can always be made"
- Read what is the [multi abi option](https://github.com/crytic/building-secure-contracts/blob/master/program-analysis/echidna/common-testing-approaches.md#external-testing)
- The `receiveTokens` callback function must be implemented
- A template is provided in [contracts/unstoppable/UnstoppableEchidna.sol](https://github.com/crytic/damn-vulnerable-defi-echidna/blob/hints/contracts/unstoppable/UnstoppableEchidna.sol)
- A config file is provided in [unstoppable.yaml](https://github.com/crytic/damn-vulnerable-defi-echidna/blob/hints/unstoppable.yaml)



## Solution

This solution can be found in the [`solutions` branch](https://github.com/crytic/damn-vulnerable-defi-echidna/blob/solutions/contracts/unstoppable/UnstoppableEchidna.sol).

[ctf]: https://www.damnvulnerabledefi.xyz/

<details>
<summary>Solution Explained (spoilers ahead)</summary>


Note: Please make sure that you have placed `solution.sol` (or `UnstoppableEchidna.sol`) in `contracts/unstoppable`. 

The goal of the unstoppable challenge is to realize that `UnstoppableLender` has two modes of tracking its balance: `poolBalance` and `damnValuableToken.balanceOf(address(this))`.

`poolBalance` is added to when someone calls `depositTokens()`.

However, a user can call `damnValuableToken.transfer()` directly and increase the `balanceOf(address(this))` without increasing `poolBalance`.

Now, the two balance trackers are out-of-sync.

When Echidna calls `pool.flashLoan(10)`, the assertion `assert(poolBalance == balanceBefore)` in `UnstoppableLender` will break and the pool can no longer provide flash loans.

See example output below from Echidna:

```bash
$ echidna-test . --contract UnstoppableEchidna --config unstoppable.yaml

...

echidna_testFlashLoan: failed!💥  
  Call sequence:
    transfer(0x62d69f6867a0a084c6d313943dc22023bc263691,1296000)

...
```
</details>
