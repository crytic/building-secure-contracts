# (Not So) Smart Contracts

This repository contains examples of common Algorand smart contract vulnerabilities, including code from real smart contracts. Use Not So Smart Contracts to learn about Algorand vulnerabilities, as a reference when performing security reviews, and as a benchmark for security and analysis tools.

## Features

Each _Not So Smart Contract_ includes a standard set of information:

- Description of the vulnerability type
- Attack scenarios to exploit the vulnerability
- Recommendations to eliminate or mitigate the vulnerability
- Real-world contracts that exhibit the flaw
- References to third-party resources with more information

## Vulnerabilities

| Not So Smart Contract                                          | Description                                                                    | Applicable to smart signatures | Applicable to smart contracts |
| -------------------------------------------------------------- | ------------------------------------------------------------------------------ | ------------------------------ | ----------------------------- |
| [Rekeying](rekeying)                                           | Attacker rekeys an account                                                     | yes                            | yes                           |
| [Unchecked Transaction Fees](unchecked_transaction_fee)        | Attacker sets excessive fees for smart signature transactions                  | yes                            | no                            |
| [Closing Account](closing_account)                             | Attacker closes smart signature accounts                                       | yes                            | no                            |
| [Closing Asset](closing_asset)                                 | Attacker transfers entire asset balance of a smart signature                   | yes                            | no                            |
| [Group Size Check](group_size_check)                           | Contract does not check transaction group size                                 | yes                            | yes                           |
| [Time-based Replay Attack](time_based_replay_attack)           | Contract does not use lease for periodic payments                              | yes                            | no                            |
| [Access Controls](access_controls)                             | Contract does not enfore access controls for updating and deleting application | no                             | yes                           |
| [Asset Id Check](asset_id_check)                               | Contract does not check asset id for asset transfer operations                 | yes                            | yes                           |
| [Denial of Service](denial_of_service)                         | Attacker stalls contract execution by opting out of a asset                    | yes                            | yes                           |
| [Inner Transaction Fee](inner_transaction_fee)                 | Inner transaction fee should be set to zero                                    | no                             | yes                           |
| [Clear State Transaction Check](clear_state_transaction_check) | Contract does not check OnComplete field of an Application Call                | yes                            | yes                           |

## Credits

These examples are developed and maintained by [Trail of Bits](https://www.trailofbits.com/).

If you have questions, problems, or just want to learn more, then join the #ethereum channel on the [Empire Hacking Slack](https://slack.empirehacking.nyc/) or [contact us](https://www.trailofbits.com/contact/) directly.
