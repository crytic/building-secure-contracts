# (Not So) Smart Contracts (Uniswap V4 Hooks)

This section contains examples of common vulnerability patterns found in Uniswap V4 hook implementations, including permission configuration, delta accounting, reentrancy, and price manipulation issues.

## Features

Each not-so-smart-contract includes:

- Description of the vulnerability type
- Attack scenarios to exploit the vulnerability
- Solidity code examples demonstrating the flaw
- Recommendations to eliminate or mitigate the vulnerability

## Vulnerabilities

| Name | Description |
|---|---|
| [Hook Permission Flag Misconfiguration](./permission_flag_misconfiguration) | Incorrect permission flags cause return deltas to be silently ignored |
| [Direct PoolManager Bypass](./direct_pool_manager_bypass) | Users bypass hook enforcement by calling PoolManager directly |
| [Hook Reentrancy](./hook_reentrancy) | Malicious hooks exploit unlock mechanisms or unsafe external calls to re-enter |
| [Hook State Overwriting](./hook_state_overwriting) | Non-keyed state variables are overwritten when hooks serve multiple pools |
| [Spot Price Manipulation in Hooks](./spot_price_manipulation) | Using slot0 spot price for calculations enables intra-transaction manipulation |
| [Delta Sign Convention Errors](./delta_sign_convention_errors) | Misinterpreting delta sign conventions causes payments to flow in the wrong direction |
| [JIT Liquidity Fee Extraction](./jit_liquidity_fee_extraction) | Fee donation mechanisms are exploitable through just-in-time concentrated liquidity |
| [Dynamic Fee Misconfiguration](./dynamic_fee_misconfiguration) | Missing the dynamic fee flag silently disables hook-controlled fee updates |

## Credits

These examples are developed and maintained by **[Trail of Bits](https://www.trailofbits.com/)**.

Contact us if you need help with smart contract security.
