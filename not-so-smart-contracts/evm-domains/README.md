# (Not So) Smart Contracts (EVM Domains)

This section contains examples of common vulnerability patterns found in specific EVM smart contract domains. Unlike general Solidity pitfalls, these issues arise from the unique logic and invariants of particular application domains such as cross-chain bridges, Merkle tree verification, concentrated liquidity AMMs, and governance systems.

## Features

Each not-so-smart-contract includes:

- Description of the vulnerability type
- Attack scenarios to exploit the vulnerability
- Solidity code examples demonstrating the flaw
- Recommendations to eliminate or mitigate the vulnerability

## Domains

| Domain | Description |
|---|---|
| [DeFi Bridge](./defi-bridge) | Vulnerabilities in cross-chain bridge protocols and aggregators |
| [Merkle Tree](./merkle-tree) | Vulnerabilities in Merkle proof verification and distribution systems |
| [Tick Math](./tick-math) | Vulnerabilities in Uniswap V3/V4-style concentrated liquidity AMMs |
| [Voting Governance](./voting-governance) | Vulnerabilities in on-chain governance and voting systems |

## Credits

These examples are developed and maintained by **[Trail of Bits](https://www.trailofbits.com/)**.

Contact us if you need help with smart contract security.
