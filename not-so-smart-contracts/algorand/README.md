# (Not So) Smart Contracts

This repository contains examples of common Algorand smart contract vulnerabilities, including code from real smart contracts. Use the Not So Smart Contracts to learn about Algorand vulnerabilities, as a reference when performing security reviews, and as a benchmark for security and analysis tools.

## Features

Each _Not So Smart Contract_ includes a standard set of information:

- Description of the vulnerability type
- Attack scenarios to exploit the vulnerability
- Recommendations for eliminating or mitigating the vulnerability
- Real-world contracts exhibiting the flaw
- References to third-party resources with more information

## Vulnerabilities

| Not So Smart Contract                                   | Description                                                                    | Applicable to smart signatures | Applicable to smart contracts |
| ------------------------------------------------------- | ------------------------------------------------------------------------------ | ------------------------------ | ----------------------------- |
| [Rekeying](rekeying)                                    | Attacker rekeys an account                                                     | yes                            | yes                           |
| [Unchecked Transaction Fees](unchecked_transaction_fee) | Attacker sets excessive fees for smart signature transactions                  | yes                            | no                            |
| [Closing Account](closing_account)                      | Attacker closes smart signature accounts                                       | yes                            | no                            |
| [Closing Asset](closing_asset)                          | Attacker transfers the entire asset balance of a smart signature               | yes                            | no                            |
| [Group Size Check](group_size_check)                    | Contract does not check transaction group size                                 | yes                            | yes                           |
| [Time-based Replay Attack](time_based_replay_attack)    | Contract does not use lease for periodic payments                              | yes                            | no                            |
| [Access Controls](access_controls)                      | Contract does not enforce access controls for updating and deleting applications | no                             | yes                           |
| [Asset Id Check](asset_id_check)                        | Contract does not check asset id for asset transfer operations                 | yes                            | yes                           |
| [Denial of Service](denial_of_service)                  | Attacker stalls contract execution by opting out of an asset                    | yes                            | yes                           |

## Credits

These examples are developed and maintained by [Trail of Bits](https://www.trailofbits.com/).

If you have questions, issues, or simply want to learn more, join the #ethereum channel on the [Empire Hacking Slack](https://empireslacking.herokuapp.com/) or [contact us](https://www.trailofbits.com/contact/) directly.
