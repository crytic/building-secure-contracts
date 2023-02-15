# Exercise 5

**Table of contents:**

- [Exercise 5](#exercise-5)
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

The challenge is described here: https://www.damnvulnerabledefi.xyz/challenges/2.html, we assume that the reader is familiar with it.


## Goals

- Setup the testing environment with the right contracts and necessary balances.
- Analyze the before function in test/naive-receiver/naive-receiver.challenge.js to identify what initial setup needs to be done.
- Add a property to check whether the balance of the `FlashLoanReceiver` contract can change.
- Create a `config.yaml` with the necessary configuration option(s).
- Once Echidna finds the bug, fix the issue, and re-try your property with Echidna.

Only the following contracts are relevant:
  - `contracts/naive-receiver/FlashLoanReceiver.sol`
  - `contracts/naive-receiver/NaiveReceiverLenderPool.sol`

## Hints

We recommend to first try without reading the following hints. The hints are in the [`hints` branch](https://github.com/crytic/damn-vulnerable-defi-echidna/tree/hints).

- Remember that sometimes you have to supply the test contract with Ether. Read more in [the Echidna wiki](https://github.com/crytic/echidna/wiki/Config) and look at [the default config setup](https://github.com/crytic/echidna/blob/master/tests/solidity/basic/default.yaml).
- The invariant that we are looking for is "the balance of the receiver contract can not decrease" 
- Read what is the [multi abi option](https://github.com/crytic/building-secure-contracts/blob/master/program-analysis/echidna/common-testing-approaches.md#external-testing)
- A template is provided in [contracts/naive-receiver/NaiveReceiverEchidna.sol](https://github.com/crytic/damn-vulnerable-defi-echidna/blob/hints/contracts/naive-receiver/NaiveReceiverEchidna.sol)
- A config file is provided in [naivereceiver.yaml](https://github.com/crytic/damn-vulnerable-defi-echidna/blob/hints/naivereceiver.yaml)


## Solution

This solution can be found in [`solutions` branch](https://github.com/crytic/damn-vulnerable-defi-echidna/blob/solutions/contracts/naive-receiver/NaiveReceiverEchidna.sol).


[ctf]: https://www.damnvulnerabledefi.xyz/

<details>
<summary>Solution Explained (spoilers ahead)</summary>

The goal of the naive receiver challenge is to realize that an arbitrary user can call request a flash loan for `FlashLoanReceiver`.
In fact, this can be done even if the arbitrary user has no ether.

Echidna found this by simply calling `NaiveReceiverLenderPool.flashLoan()` with the address of `FlashLoanReceiver` and any arbitrary amount.

See example output below from Echidna:

```bash
$ echidna-test . --contract NaiveReceiverEchidna --config naivereceiver.yaml
...

echidna_test_contract_balance: failed!💥  
  Call sequence:
    flashLoan(0x62d69f6867a0a084c6d313943dc22023bc263691,353073667)

...
```
</details>


