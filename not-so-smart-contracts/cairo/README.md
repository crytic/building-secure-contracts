# (Not So) Smart Contracts

This repository contains examples of common Cairo smart contract vulnerabilities, featuring code from real smart contracts. Utilize the Not So Smart Contracts to learn about Cairo vulnerabilities, refer to them during security reviews, and use them as a benchmark for security analysis tools.

## Features

Each _Not So Smart Contract_ consists of a standard set of information:

- Vulnerability type description
- Attack scenarios to exploit the vulnerability
- Recommendations to eliminate or mitigate the vulnerability
- Real-world contracts exhibiting the flaw
- References to third-party resources providing more information

## Vulnerabilities

| Not So Smart Contract                                                        | Description                                                  |
| ---------------------------------------------------------------------------- | ------------------------------------------------------------ |
| [Arithmetic overflow](arithmetic_overflow)                                   | Insecure arithmetic in Cairo for the felt252 type            |
| [L1 to L2 Address Conversion](L1_to_L2_address_conversion)                   | Essential L2 address checks for L1 to L2 messaging           |
| [L1 to L2 message failure](l1_to_l2_message_failure)                         | Messages sent from L1 may not be processed by the sequencer  |
| [Overconstrained L1 <-> L2 interaction](overconstrained_l1_l2_interaction)   | Asymmetrical checks on the L1 or L2 side can cause a DOS     |
| [Signature replays](replay_protection)                                       | Necessary robust reuse protection due to account abstraction |
| [Unchecked from address in L1 Handler](unchecked_from_address_in_l1_handler) | Access control issue when sending messages from L1 to L2     |

## Credits

These examples are developed and maintained by [Trail of Bits](https://www.trailofbits.com/).

If you have any questions, issues, or wish to learn more, join the #ethereum channel on the [Empire Hacking Slack](https://slack.empirehacking.nyc/) or [contact us](https://www.trailofbits.com/contact/) directly.
