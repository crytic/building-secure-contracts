# (Not So) Smart Contracts (Domain-Specific Vulnerabilities)

This section contains examples of common vulnerability patterns found in specific smart contract domains. Unlike general Solidity pitfalls, these issues arise from the unique logic and invariants of particular application domains such as cross-chain bridges, account abstraction, AMMs, and governance systems.

## Features

Each not-so-smart-contract includes:

- Description of the vulnerability type
- Attack scenarios to exploit the vulnerability
- Solidity code examples demonstrating the flaw
- Recommendations to eliminate or mitigate the vulnerability

## Vulnerabilities

| Name                                     | Description                                                                      |
| ---------------------------------------- | -------------------------------------------------------------------------------- |
| [DeFi Bridge](./defi_bridge)             | Vulnerabilities in cross-chain bridge protocols and aggregators                  |
| [ERC-4337](./erc4337)                    | Vulnerabilities in account abstraction: smart accounts, paymasters, and bundlers |
| [Merkle Tree](./merkle_tree)             | Vulnerabilities in Merkle proof verification and distribution systems            |
| [Precision Loss](./precision_loss)       | Vulnerabilities in arithmetic precision, rounding, and decimal handling          |
| [Slippage](./slippage)                   | Vulnerabilities in slippage protection across DeFi operations                    |
| [Tick Math](./tick_math)                 | Vulnerabilities in Uniswap V3/V4-style concentrated liquidity AMMs               |
| [Uniswap V4 Hooks](./uniswap_v4_hooks)   | Vulnerabilities in Uniswap V4 hook implementations                               |
| [Voting Governance](./voting_governance) | Vulnerabilities in on-chain governance and voting systems                        |

## Credits

These examples are developed and maintained by **[Trail of Bits](https://www.trailofbits.com/)**.

Contact us if you need help with smart contract security.
