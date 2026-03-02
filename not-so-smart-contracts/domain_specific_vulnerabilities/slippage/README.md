# (Not So) Smart Contracts (Slippage)

This section contains examples of common vulnerability patterns in slippage protection across DeFi protocols, including swaps, liquidity operations, and multi-step transactions.

## Features

Each not-so-smart-contract includes:

- Description of the vulnerability type
- Attack scenarios to exploit the vulnerability
- Solidity code examples demonstrating the flaw
- Recommendations to eliminate or mitigate the vulnerability

## Vulnerabilities

| Name                                                                     | Description                                                                                                                     |
| ------------------------------------------------------------------------ | ------------------------------------------------------------------------------------------------------------------------------- |
| [Missing Slippage Protection](./missing_slippage_protection)             | Swap and liquidity operations that accept any output amount expose users to unlimited sandwich attack losses                    |
| [On-Chain Slippage Calculation](./onchain_slippage_calculation)          | Computing slippage bounds from on-chain state at execution time provides no protection because the state is already manipulated |
| [Hardcoded Slippage Values](./hardcoded_slippage_values)                 | Fixed slippage tolerances are either too tight, causing denial of service, or too loose, enabling extraction                    |
| [Missing Expiration Deadline](./missing_expiration_deadline)             | Transactions without deadlines can remain pending indefinitely and execute at unfavorable times                                 |
| [Unapplied Slippage Parameters](./unapplied_slippage_parameters)         | Slippage parameters that are validated but never forwarded to the actual swap provide false safety                              |
| [Shared Slippage Across Operations](./shared_slippage_across_operations) | Reusing a single slippage value for multiple operations with different characteristics leads to insufficient protection         |
| [Slippage Check at Wrong Stage](./wrong_stage_slippage_check)            | Verifying slippage before fees or against intermediate values instead of the final output renders the check ineffective         |
| [Unprotected Share Minting](./unprotected_minting)                       | Minting shares or LP tokens based on manipulable on-chain reserves without minimum output checks enables donation attacks       |

## Credits

These examples are developed and maintained by **[Trail of Bits](https://www.trailofbits.com/)**.

Contact us if you need help with smart contract security.
