# (Not So) Smart Cosmos

This repository contains examples of common Cosmos application vulnerabilities, including code from real applications. Use Not So Smart Cosmos to learn about Cosmos (Tendermint) vulnerabilities, as a reference for conducting security reviews, and as a benchmark for security and analysis tools.

## Features

Each _Not So Smart Cosmos_ entry provides a standard set of information:

- Description of the vulnerability type
- Attack scenarios to exploit the vulnerability
- Recommendations for eliminating or mitigating the vulnerability
- Real-world contracts that exhibit the flaw
- References to third-party resources with more information

## Vulnerabilities

| Not So Smart Contract                                  | Description                                                                                   |
| ------------------------------------------------------ | --------------------------------------------------------------------------------------------- |
| [Incorrect signers](incorrect_getsigners)              | Broken access controls due to incorrect signer validation                                     |
| [Non-determinism](non_determinism)                     | Consensus failure due to non-determinism                                                      |
| [Not prioritized messages](messages_priority)          | Risks arising from use of non-prioritized message types                                      |
| [Slow ABCI methods](abci_fast)                         | Consensus failure due to slow ABCI methods                                                    |
| [ABCI methods panic](abci_panic)                       | Chain halt due to panic in ABCI methods                                                       |
| [Broken bookkeeping](broken_bookkeeping)               | Exploiting mismatch between different modules' views on balances                              |
| [Rounding errors](rounding_errors)                     | Bugs related to imprecision in finite precision arithmetic                                    |
| [Unregistered message handler](unregistered_msg_handler)| Broken functionality due to unregistered msg handler                                          |
| [Missing error handler](missing_error_handler)         | Missing error handling results in the successful execution of a transaction that should fail |

## Credits

These examples are developed and maintained by [Trail of Bits](https://www.trailofbits.com/).

If you have questions, encounter problems, or want to learn more, join the #ethereum channel on the [Empire Hacking Slack](https://empireslacking.herokuapp.com/) or [contact us](https://www.trailofbits.com/contact/) directly.
