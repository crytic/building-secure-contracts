# (Not So) Smart Cosmos

This repository contains examples of common Cosmos applications vulnerabilities, including code from real applications. Use Not So Smart Cosmos to learn about Cosmos (Tendermint) vulnerabilities, as a reference when performing security reviews, and as a benchmark for security and analysis tools.

## Features

Each _Not So Smart Cosmos_ includes a standard set of information:

- Description of the vulnerability type
- Attack scenarios to exploit the vulnerability
- Recommendations to eliminate or mitigate the vulnerability
- Real-world contracts that exhibit the flaw
- References to third-party resources with more information

## Vulnerabilities

| Not So Smart Contract                                    | Description                                                                                   |
| -------------------------------------------------------- | --------------------------------------------------------------------------------------------- |
| [Incorrect signers](incorrect_getsigners)                | Broken access controls due to incorrect signers validation                                    |
| [Non-determinism](non_determinism)                       | Consensus failure because of non-determinism                                                  |
| [Not prioritized messages](messages_priority)            | Risks arising from usage of not prioritized message types                                     |
| [Slow ABCI methods](abci_fast)                           | Consensus failure because of slow ABCI methods                                                |
| [ABCI methods panic](abci_panic)                         | Chain halt due to panics in ABCI methods                                                      |
| [Broken bookkeeping](broken_bookkeeping)                 | Exploit mismatch between different modules' views on balances                                 |
| [Rounding errors](rounding_errors)                       | Bugs related to imprecision of finite precision arithmetic                                    |
| [Unregistered message handler](unregistered_msg_handler) | Broken functionality because of unregistered msg handler                                      |
| [Missing error handler](missing_error_handler)           | Missing error handling leads to successful execution of a transaction that should have failed |

## Credits

These examples are developed and maintained by [Trail of Bits](https://www.trailofbits.com/).

If you have questions, problems, or just want to learn more, then join the #ethereum channel on the [Empire Hacking Slack](https://slack.empirehacking.nyc/) or [contact us](https://www.trailofbits.com/contact/) directly.
