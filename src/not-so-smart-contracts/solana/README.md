# (Not So) Smart Contracts

This repository contains examples of common Solana smart contract vulnerabilities, including code from real smart contracts. Use Not So Smart Contracts to learn about Solana vulnerabilities, as a reference when performing security reviews, and as a benchmark for security and analysis tools.

## Features

Each _Not So Smart Contract_ includes a standard set of information:

- Description of the vulnerability type
- Attack scenarios to exploit the vulnerability
- Recommendations to eliminate or mitigate the vulnerability
- Real-world contracts that exhibit the flaw
- References to third-party resources with more information

## Vulnerabilities

| Not So Smart Contract                                                    | Description                                               |
| ------------------------------------------------------------------------ | --------------------------------------------------------- |
| [Arbitrary CPI](arbitrary_cpi)                                           | Arbitrary program account passed in upon invocation       |
| [Improper PDA Validation](improper_pda_validation)                       | PDAs are vulnerable to being spoofed via bump seeds       |
| [Ownership Check](ownership_check)                                       | Broken access control due to missing ownership validation |
| [Signer Check](signer_check)                                             | Broken access control due to missing signer validation    |
| [Sysvar Account Check](sysvar_account_check)                             | Sysvar accounts are vulnerable to being spoofed           |
| [Improper Instruction Introspection](improper_instruction_introspection) | Program accesses instruction using absolute index         |

## Credits

These examples are developed and maintained by [Trail of Bits](https://www.trailofbits.com/).

If you have questions, problems, or just want to learn more, then join the #solana channel on the [Empire Hacking Slack](https://slack.empirehacking.nyc/) or [contact us](https://www.trailofbits.com/contact/) directly.
