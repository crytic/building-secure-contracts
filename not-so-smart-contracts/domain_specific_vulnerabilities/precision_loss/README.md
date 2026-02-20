# (Not So) Smart Contracts (Precision Loss)

This section contains examples of common precision loss and rounding vulnerabilities in DeFi protocols, including arithmetic ordering errors, rounding direction mistakes, and decimal handling issues.

## Features

Each not-so-smart-contract includes:

- Description of the vulnerability type
- Attack scenarios to exploit the vulnerability
- Solidity code examples demonstrating the flaw
- Recommendations to eliminate or mitigate the vulnerability

## Vulnerabilities

| Name | Description |
|---|---|
| [Division Before Multiplication](./division_before_multiplication) | Performing division before multiplication causes intermediate truncation that can reduce results to zero |
| [Incorrect Rounding Direction](./incorrect_rounding_direction) | Rounding in a direction that favors users over the protocol enables value extraction through repeated operations |
| [Ratio Truncation to Zero](./ratio_truncation_to_zero) | When a ratio in a formula truncates to zero, the formula can collapse to return the entire pool balance to the attacker |
| [Conflicting Rounding Requirements](./conflicting_rounding_requirements) | Reusing a single intermediate value for calculations that need opposite rounding directions guarantees one of them is wrong |
| [Rounding-Induced Denial of Service](./rounding_induced_dos) | Rounding up a computed value can cause it to exceed actual balances, reverting critical operations like withdrawals |
| [Decimal Mismatch](./decimal_mismatch) | Assuming all tokens use 18 decimals causes massive over- or under-valuation when interacting with tokens of different precision |
| [Fee Truncation Bypass](./fee_truncation_bypass) | Fees on small amounts truncate to zero, allowing users to avoid fees entirely by splitting operations |

## Credits

These examples are developed and maintained by **[Trail of Bits](https://www.trailofbits.com/)**.

Contact us if you need help with smart contract security.
