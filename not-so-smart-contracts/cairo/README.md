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

| Not So Smart Contract                                                          | Description                                                  |
| ------------------------------------------------------------------------------ | ------------------------------------------------------------ |
| [Improper access controls](access_controls)                                    | Flawed access controls due to StarkNet account abstraction   |
| [Integer division errors](integer_division)                                    | Unforeseen results from division in a finite field           |
| [View state modifications](view_state)                                         | Lack of prevention for state modifications in view functions |
| [Arithmetic overflow](arithmetic_overflow)                                     | Insecure arithmetic in Cairo by default                      |
| [Signature replays](replay_protection)                                         | Necessary robust reuse protection due to account abstraction |
| [L1 to L2 Address Conversion](L1_to_L2_address_conversion)                     | Essential L2 address checks for L1 to L2 messaging           |
| [Incorrect Felt Comparison](incorrect_felt_comparison)                         | Unexpected results from felt comparison                      |
| [Namespace Storage Var Collision](namespace_storage_var_collision)             | Storage variables unscoped by namespaces                     |
| [Dangerous Public Imports in Libraries](dangerous_public_imports_in_libraries) | Ability to call nonimported external functions               |

## Credits

These examples are developed and maintained by [Trail of Bits](https://www.trailofbits.com/).

If you have any questions, issues, or wish to learn more, join the #ethereum channel on the [Empire Hacking Slack](https://slack.empirehacking.nyc/) or [contact us](https://www.trailofbits.com/contact/) directly.
