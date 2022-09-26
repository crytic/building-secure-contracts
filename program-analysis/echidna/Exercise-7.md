# Exercise 7

**Table of contents:**

- [Exercise 7](#exercise-7)
  - [Setup](#setup)
  - [Exercise](#exercise)
  - [Solution](#solution)

Join the team on Slack at: https://empireslacking.herokuapp.com/ #ethereum

## Setup

1. Follow the instructions on the [Damn Vulnerable DeFi CTF][ctf] page, namely:
    - clone the repo via `git clone https://github.com/tinchoabbate/damn-vulnerable-defi -b v2.0.0`, and
    - install the dependencies via `yarn install`.
2. To run Echidna on these contracts you must comment out the `dependencyCompiler` section in `hardhat.config.js`. Otherwise, the project will not compile with [`crytic-compile`](https://github.com/crytic/crytic-compile). See the example provided [here](./exercises/exercise7/example.hardhat.config.ts).
3. TODO

No skeleton will be provided for this exercise.

## Goals

- Setup the testing environment with the right contracts and necessary balances.
- Add a property to check whether the balance of the `FlashLoanReceiver` contract can change.
- Create a `config.yaml` with the necessary configuration option(s).
- Once Echidna finds the bug, fix the issue, and re-try your property with Echidna.

Hint: You might have to use the `multi-abi` configuration option in this exercise.
## Solution

This solution can be found in [exercises/exercise7/solution.sol](./exercises/exercise7/solution.sol)

[ctf]: https://www.damnvulnerabledefi.xyz/

<details>
<summary>Solution Explained (spoilers ahead)</summary>
TODO
</details>


