# Exercise 5

**Table of contents:**

- [Exercise 5](#exercise-5)
  - [Setup](#setup)
  - [Exercise](#exercise)
  - [Solution](#solution)

Join the team on Slack at: https://empireslacking.herokuapp.com/ #ethereum

## Setup

1. Follow the instructions on the [Damn Vulnerable DeFi CTF][ctf] page, namely:
    - clone the repo, and
    - install the dependencies.
2. Create a contract called `UnstoppableEchidna` in the `contract/unstoppable` directory.
3. Analyze the `before` function in `test/unstoppable/unstoppable.challenge.js` to identify what initial setup needs to be done.

Hint: You don't need to make the setup very complex. It is possible to find the bug with just three contracts:
  - `DamnValuableToken`
  - `UnstoppableLender`
  - `ReceiverUnstoppable`

## Goals

- Setup the testing environment with the right contracts and necessary balances.
- Add a property to check whether `UnstoppableLender` can always provide flash loans.
- Create `config.yaml` with the necessary configuration option(s).
- Once Echidna finds the bug, fix the issue, and re-try your property with Echidna.

## Solution

This solution can be found in [exercises/exercise5/solution.sol](./exercises/exercise5/solution.sol)

[ctf]: https://www.damnvulnerabledefi.xyz/

<details>
<summary>Solution Explained (spoilers ahead)</summary>

The goal of the unstoppable challenge is to realize that `UnstoppableLender` has two modes of tracking its balance: `poolBalance` and `damnValuableToken.balanceOf(address(this))`.

`poolBalance` is added to when someone calls `depositTokens()`.

However, a user can call `damnValuableToken.transfer()` directly and increase the `balanceOf(address(this))` without increasing `poolBalance`.

Now, the two balance trackers are out-of-sync.

When Echidna calls `pool.flashLoan(10)`, the assertion `assert(poolBalance == balanceBefore)` in `UnstoppableLender` will break and the pool can no longer provide flash loans.

See example output below from Echidna:

```bash
No output :(
```
</details>
