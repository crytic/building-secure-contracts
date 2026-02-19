# (Not So) Smart Contracts (DeFi Bridge)

This section contains examples of common vulnerability patterns found in cross-chain bridge protocols and bridge aggregators. These issues arise from the complexity of managing state, tokens, and messages across multiple blockchain networks.

## Features

Each not-so-smart-contract includes:

- Description of the vulnerability type
- Attack scenarios to exploit the vulnerability
- Solidity code examples demonstrating the flaw
- Recommendations to eliminate or mitigate the vulnerability

## Vulnerabilities

| Name | Description |
|---|---|
| [Arbitrary External Calls](./arbitrary_external_calls) | Bridge facets that allow user-controlled call targets enable token theft |
| [Cross-Chain Message Authentication Bypass](./cross_chain_message_authentication) | Missing validation of message source chain or sender allows forged messages |
| [Native Token Handling Inconsistency](./native_token_handling) | Different native token representations across chains cause bridging failures |
| [Missing Recovery Mechanisms](./missing_recovery_mechanisms) | Absence of fund recovery paths causes permanent loss on failed operations |
| [Unchecked Return Values](./unchecked_return_values) | Silent failures from unchecked low-level calls cause fund loss |
| [ERC-777 Reentrancy](./erc777_reentrancy) | ERC-777 token callbacks enable reentrancy in balance-difference accounting |
| [Cross-Chain Address Assumptions](./cross_chain_address_assumptions) | Assuming address equivalence across chains leads to fund theft |
| [Gas Griefing](./gas_griefing) | Insufficient gas forwarding causes permanent message channel blockage |

## Credits

These examples are developed and maintained by **[Trail of Bits](https://www.trailofbits.com/)**.

Contact us if you need help with smart contract security.
