# (Not So) Smart Contracts (Soroban)

This repository contains examples of common Soroban (Stellar) smart contract vulnerabilities, including code from real smart contracts. Use Not So Smart Contracts to learn about Soroban vulnerabilities, as a reference when performing security reviews, and as a benchmark for security and analysis tools.

## Features

Each _Not So Smart Contract_ includes:

- Description of the vulnerability type
- Attack scenarios to exploit the vulnerability
- Recommendations to eliminate or mitigate the vulnerability

## Vulnerabilities

| Name                                                           | Description                                                                       |
| -------------------------------------------------------------- | --------------------------------------------------------------------------------- |
| [Missing Authorization](./missing_require_auth)                | Privileged functions never call `require_auth` on the affected address            |
| [Unbound Authorization](./unbound_authorization)               | `require_auth` is called on a caller-supplied address instead of the stored one   |
| [Unprotected Upgrade](./unprotected_upgrade)                   | Anyone can replace the contract's Wasm and take over its storage and funds        |
| [Re-initialization](./reinitialization)                        | An `initialize` function can be called again to overwrite the admin               |
| [Temporary Storage Misuse](./temporary_storage_misuse)         | Security-critical state in `temporary` storage is deleted when its TTL expires    |
| [Negative Amounts](./negative_amounts)                         | Signed `i128` amounts are not checked for negative values                         |
| [Integer Truncation](./integer_truncation)                     | `as` casts silently truncate values, even with `overflow-checks` enabled          |
| [Unvalidated Contract Address](./unvalidated_contract_address) | A caller-supplied contract address is trusted as the real token                   |
| [Resource Limit Denial of Service](./resource_limit_dos)       | Unbounded storage or loops exceed per-transaction resource limits                 |
| [Custom Account Auth Context](./custom_account_auth_context)   | `__check_auth` verifies signatures but not what the signatures authorize          |
| [Stellar Asset Issuer Controls](./asset_issuer_controls)       | Clawback and deauthorization break contracts that assume token balances are final |
| [Thin Market Oracle Manipulation](./oracle_manipulation)       | Prices from illiquid markets are inflated to over-borrow against collateral       |

## Credits

These examples are developed and maintained by **[Trail of Bits](https://www.trailofbits.com/)**.

Contact us if you need help with smart contract security.
