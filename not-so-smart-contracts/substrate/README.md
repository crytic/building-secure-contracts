# (Not So) Smart Pallets

This repository contains examples of common vulnerabilities in Substrate pallets. Use the Not So Smart Pallets to learn about Substrate vulnerabilities, as a reference for performing security reviews, and as a benchmark for security analysis tools.

## Features

Each _Not So Smart Pallet_ includes a standard set of information:

- Description of the vulnerability type
- Attack scenarios for exploiting the vulnerability
- Recommendations for eliminating or mitigating the vulnerability
- A mock pallet that exhibits the flaw
- References to third-party resources with more information

## Vulnerabilities

| Not So Smart Pallet                                  | Description                                                            |
| ---------------------------------------------------- | ---------------------------------------------------------------------- |
| [Arithmetic overflow](arithmetic_overflow)           | Integer overflow due to incorrect use of arithmetic operators          |
| [Don't panic!](dont_panic)                           | System panics create a potential DoS attack vector                     |
| [Weights and fees](weights_and_fees)                 | Incorrect weight calculations can create a potential DoS attack vector |
| [Verify first](verify_first)                         | Verify first, write last                                               |
| [Unsigned transaction validation](validate_unsigned) | Insufficient validation of unsigned transactions                       |
| [Bad randomness](randomness)                         | Unsafe sources of randomness in Substrate                              |
| [Bad origin](origins)                                | Incorrect use of call origin can lead to bypassing access controls     |

## Credits

These examples are developed and maintained by [Trail of Bits](https://www.trailofbits.com/).

If you have questions, need assistance, or just want to learn more, then join the #ethereum channel on the [Empire Hacking Slack](https://empireslacking.herokuapp.com/) or [contact us](https://www.trailofbits.com/contact/) directly.
