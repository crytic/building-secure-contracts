# (Not So) Smart Contracts (Sui)

This repository contains examples of common Sui Move smart contract vulnerabilities, including code from real smart contracts. Use Not So Smart Contracts to learn about Sui vulnerabilities, as a reference when performing security reviews, and as a benchmark for security and analysis tools.

## Features

Each _Not So Smart Contract_ includes:

- Description of the vulnerability type
- Attack scenarios to exploit the vulnerability
- Recommendations to eliminate or mitigate the vulnerability

## Vulnerabilities

| Name | Description |
|---|---|
| [Mutable Reference Shadowing](./mutable_reference_shadowing) | Destructured `mut` bindings silently fail to write through to struct fields |
| [Unvalidated Shared Object Identity](./unvalidated_object_identity) | Functions accept any shared object of the correct type without ID validation |
| [Verifier Bypass via Package Upgrade](./verifier_bypass_via_upgrade) | Adding `key` ability on upgrade bypasses the `id_leak_verifier` |
| [Runtime Limit Denial of Service](./runtime_limit_dos) | Hard runtime limits abort on shared objects causing permanent denial of service |
| [Missing Object Uniqueness](./missing_object_uniqueness) | No built-in one-per-address constraint allows duplicate singleton objects |
| [Type Parameter Griefing](./type_parameter_griefing) | Callers substitute wrong generic types to destroy state before validation |

## Credits

These examples are developed and maintained by **[Trail of Bits](https://www.trailofbits.com/)**.

Contact us if you need help with smart contract security.
