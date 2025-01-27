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

| Not So Smart Contract                                          | Description                                                 |
| -------------------------------------------------------------- | ----------------------------------------------------------- |
| [Int as boolean](int_as_boolean)                               | Unexpected result of logical operations on the int type     |
| [Fake Jetton contract](fake_jetton_contract)                   | Any contract can send a `transfer_notification` message     |
| [Forward TON without gas check](forward_ton_without_gas_check) | Users can drain TON balance of a contract lacking gas check |

## Credits

These examples are developed and maintained by [Trail of Bits](https://www.trailofbits.com/).

If you have any questions, issues, or wish to learn more, join the #ethereum channel on the [Empire Hacking Slack](https://slack.empirehacking.nyc/) or [contact us](https://www.trailofbits.com/contact/) directly.
