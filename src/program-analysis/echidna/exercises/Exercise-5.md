# Exercise 5

**Table of contents:**

- [Exercise 5](#exercise-5)
  - [Setup](#setup)
  - [Context](#context)
  - [Goals](#goals)
  - [Hints](#hints)
  - [Solution](#solution)

Join the team on Slack at: https://slack.empirehacking.nyc/ #ethereum

## Setup

1. Clone the repo: `git clone https://github.com/crytic/damn-vulnerable-defi-echidna`
2. Install the dependencies by running `yarn install`.

## Context

The challenge is described here: https://www.damnvulnerabledefi.xyz/challenges/2.html. It is assumed that the reader is familiar with the challenge.

## Goals

- Set up the testing environment with the correct contracts and necessary balances.
- Analyze the "before" function in test/naive-receiver/naive-receiver.challenge.js to identify the required initial setup.
- Add a property to check if the balance of the `FlashLoanReceiver` contract can change.
- Create a `config.yaml` with the necessary configuration option(s).
- Once Echidna finds the bug, fix the issue and re-test your property with Echidna.

The following contracts are relevant:

- `contracts/naive-receiver/FlashLoanReceiver.sol`
- `contracts/naive-receiver/NaiveReceiverLenderPool.sol`

## Hints

It is recommended to first attempt without reading the hints. The hints can be found in the [`hints` branch](https://github.com/crytic/damn-vulnerable-defi-echidna/tree/hints).

- Remember that you might need to supply the test contract with Ether. Read more in [the Echidna wiki](https://github.com/crytic/echidna/wiki/Config) and check [the default config setup](https://github.com/crytic/echidna/blob/master/tests/solidity/basic/default.yaml).
- The invariant to look for is that "the balance of the receiver contract cannot decrease."
- Learn about the [allContracts optio](../basic/common-testing-approaches.md#external-testing).
- A template is provided in [contracts/naive-receiver/NaiveReceiverEchidna.sol](https://github.com/crytic/damn-vulnerable-defi-echidna/blob/hints/contracts/naive-receiver/NaiveReceiverEchidna.sol).
- A config file is provided in [naivereceiver.yaml](https://github.com/crytic/damn-vulnerable-defi-echidna/blob/hints/naivereceiver.yaml).

## Solution

The solution can be found in the [`solutions` branch](https://github.com/crytic/damn-vulnerable-defi-echidna/blob/solutions/contracts/naive-receiver/NaiveReceiverEchidna.sol).

[ctf]: https://www.damnvulnerabledefi.xyz/

<details>
<summary>Solution Explained (spoilers ahead)</summary>

The goal of the naive receiver challenge is to realize that any user can request a flash loan for `FlashLoanReceiver`, even if the user has no Ether.

Echidna discovers this by calling `NaiveReceiverLenderPool.flashLoan()` with the address of `FlashLoanReceiver` and any arbitrary amount.

See the example output from Echidna below:

```bash
echidna . --contract NaiveReceiverEchidna --config naivereceiver.yaml
...

echidna_test_contract_balance: failed!💥
  Call sequence:
    flashLoan(0x62d69f6867a0a084c6d313943dc22023bc263691,353073667)

...
```

</details>
