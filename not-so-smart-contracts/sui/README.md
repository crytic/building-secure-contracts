# (Not So) Smart Contracts

This repository contains examples of common Sui Move smart contract vulnerabilities, including code from real smart contracts. Use Not So Smart Contracts to learn about Sui vulnerabilities, as a reference when performing security reviews, and as a benchmark for security and analysis tools.

## Features

Each _Not So Smart Contract_ includes a standard set of information:

- Description of the vulnerability type
- Attack scenarios to exploit the vulnerability
- Recommendations to eliminate or mitigate the vulnerability
- Real-world contracts that exhibit the flaw
- References to third-party resources with more information

## Vulnerabilities

| Not So Smart Contract                                          | Description                                                                     |
| -------------------------------------------------------------- | ------------------------------------------------------------------------------- |
| [Mutable Reference Shadowing](mutable_reference_shadowing)     | Destructured `mut` bindings silently fail to write through to struct fields      |
| [Arithmetic Overflow Abort](arithmetic_overflow_abort)          | Overflow aborts brick shared objects into permanent denial of service            |
| [Unvalidated Shared Object Identity](unvalidated_object_identity) | Functions accept any shared object of the correct type without ID validation  |
| [Verifier Bypass via Package Upgrade](verifier_bypass_via_upgrade) | Adding `key` ability on upgrade bypasses the `id_leak_verifier`              |
| [Runtime Limit Denial of Service](runtime_limit_dos)           | Hard runtime limits (dynamic fields, object size, gas) abort on shared objects  |
| [Framework Hash Domain Separation](framework_hash_domain_separation) | Variable-length hash concatenation without length prefixes enables collisions |
| [Missing Object Uniqueness](missing_object_uniqueness)         | No built-in one-per-address constraint allows duplicate singleton objects       |
| [Type Parameter Griefing](type_parameter_griefing)              | Callers substitute wrong generic types to destroy state before validation       |

## Credits

These examples are developed and maintained by [Trail of Bits](https://www.trailofbits.com/).

If you have questions, problems, or just want to learn more, then join the #blockchain channel on the [Empire Hacking Slack](https://slack.empirehacking.nyc/) or [contact us](https://www.trailofbits.com/contact/) directly.
