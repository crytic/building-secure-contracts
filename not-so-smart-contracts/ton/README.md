# (Not So) Smart Contracts

This repository contains examples of common TON smart contract vulnerabilities, featuring code from real smart contracts. Utilize the Not So Smart Contracts to learn about TON vulnerabilities, refer to them during security reviews, and use them as a benchmark for security analysis tools.

## Features

Each _Not So Smart Contract_ consists of a standard set of information:

- Vulnerability type description
- Attack scenarios to exploit the vulnerability
- Recommendations to eliminate or mitigate the vulnerability
- Real-world contracts exhibiting the flaw
- References to third-party resources providing more information

## Vulnerabilities

| Not So Smart Contract                                          | Description                                                             |
| -------------------------------------------------------------- | ----------------------------------------------------------------------- |
| [Int as boolean](int_as_boolean)                               | Unexpected result of logical operations on the int type                 |
| [Fake Jetton contract](fake_jetton_contract)                   | Any contract can send a `transfer_notification` message                 |
| [Forward TON without gas check](forward_ton_without_gas_check) | Users can drain TON balance of a contract lacking gas check             |
| [Missing Bounce Handler](missing_bounce_handler)               | Bounceable messages without bounce processing cause fund loss           |
| [Irreversible State Changes](irreversible_state_changes)       | Multi-contract flows leave state inconsistent on failure                |
| [Raw Reserve Before Validation](raw_reserve_before_validation) | Calling `raw_reserve` before checks locks funds permanently             |
| [Unvalidated Storage Upgrade](unvalidated_storage_upgrade)     | Saving unvalidated cells via `set_data` bricks the contract             |
| [Single-Step Ownership Transfer](single_step_ownership_transfer) | One-step admin changes are irrevocable if the address is wrong        |
| [Missing `impure` Specifier](missing_impure_specifier)         | Functions without `impure` can be removed by the FunC compiler          |
| [Silent Message Failure](silent_message_failure)               | `SendIgnoreErrors` silently drops messages when balance is insufficient |
| [Race Conditions](race_conditions)                             | Concurrent message flows corrupt shared state                           |

## Credits

These examples are developed and maintained by [Trail of Bits](https://www.trailofbits.com/).

If you have any questions, issues, or wish to learn more, join the #ethereum channel on the [Empire Hacking Slack](https://slack.empirehacking.nyc/) or [contact us](https://www.trailofbits.com/contact/) directly.
