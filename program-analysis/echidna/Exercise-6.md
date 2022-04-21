# Exercise 6

**Table of contents:**

- [Exercise 6](#exercise-6)
  - [Setup](#setup)
  - [Exercise](#exercise)
  - [Solution](#solution)

Join the team on Slack at: https://empireslacking.herokuapp.com/ #ethereum

## Setup

1. Follow the instructions on the [Damn Vulnerable DeFi CTF][ctf] page, namely:
    - clone the repo via `git clone https://github.com/tinchoabbate/damn-vulnerable-defi -b v2.0.0`, and
    - install the dependencies via `yarn install`.
2. To run Echidna on these contracts you must comment out the `dependencyCompiler` section in `hardhat.config.js`. Otherwise, the project will not compile with [`crytic-compile`](https://github.com/crytic/crytic-compile). See the example provided [here](./exercises/exercise6/example.hardhat.config.ts).
3. Create a contract called `TestNaiveReceiverEchidna` in the `contracts/naive-receiver` directory.
4. Analyze the `before` function in `test/naive-receiver/naive-receiver.challenge.js` to identify what initial setup needs to be done.

Hint: You don't need to make the setup very complex. It is possible to find the bug by examining just two contracts:
  - `FlashLoanReceiver`
  - `NaiveReceiverLenderPool.sol`

No skeleton will be provided for this exercise.

## Goals

- Setup the testing environment with the right contracts and necessary balances.
- Add a property to check whether the balance of the `FlashLoanReceiver` contract can change.
- Create a `config.yaml` with the necessary configuration option(s).
- Once Echidna finds the bug, fix the issue, and re-try your property with Echidna.

Hint: You might have to use the `multi-abi` configuration option in this exercise.
## Solution

This solution can be found in [exercises/exercise6/solution.sol](./exercises/exercise6/solution.sol)

[ctf]: https://www.damnvulnerabledefi.xyz/

<details>
<summary>Solution Explained (spoilers ahead)</summary>

Note: Please make sure that you have placed `solution.sol` (or `TestNaiveReceiverEchidna.sol`) in `contracts/naive-receiver`. 


The goal of the naive receiver challenge is to realize that an arbitrary user can call request a flash loan for `FlashLoanReceiver`.
In fact, this can be done even if the arbitrary user has no ether.

Echidna found this by simply calling `NaiveReceiverLenderPool.flashLoan()` with the address of `FlashLoanReceiver` and any arbitrary amount.

See example output below from Echidna:

```bash
$ npx hardhat clean && npx hardhat compile --force && echidna-test . --contract TestNaiveReceiverEchidna --multi-abi --config contracts/naive-receiver/config.yaml
...

echidna_test_contract_balance: failed!💥  
  Call sequence:
    flashLoan(0x62d69f6867a0a084c6d313943dc22023bc263691,353073667)

...
```
</details>


