# (Not So) Smart Contracts (ERC-4337)

This section contains examples of common vulnerability patterns found in ERC-4337 Account Abstraction implementations, including smart accounts, paymasters, bundlers, and modular validation systems.

## Features

Each not-so-smart-contract includes:

- Description of the vulnerability type
- Attack scenarios to exploit the vulnerability
- Solidity code examples demonstrating the flaw
- Recommendations to eliminate or mitigate the vulnerability

## Vulnerabilities

| Name                                                                       | Description                                                                                                     |
| -------------------------------------------------------------------------- | --------------------------------------------------------------------------------------------------------------- |
| [Missing EntryPoint in Operation Hash](./missing_entrypoint_in_hash)       | Omitting the EntryPoint address from the user operation hash enables replay across EntryPoint upgrades          |
| [Cross-Chain Operation Replay](./cross_chain_operation_replay)             | Missing chain identifier in signature hashes allows replaying signed operations on other chains                 |
| [Paymaster Deposit Drain via Signature Replay](./paymaster_deposit_drain)  | Paymasters that do not track used signatures can have their deposits drained through repeated submission        |
| [Bundler Gas Manipulation](./bundler_gas_manipulation)                     | Malicious bundlers can submit operations with insufficient gas, causing failures while still collecting payment |
| [Unvalidated Gas Parameters in Paymaster](./unvalidated_gas_parameters)    | Paymasters that accept arbitrary gas values allow attackers to drain deposits in a single operation             |
| [Account Creation Frontrunning](./account_creation_frontrunning)           | CREATE2 salts that do not bind the owner allow attackers to frontrun account deployment and steal funds         |
| [Incorrect Validation Return Values](./incorrect_validation_return_values) | Returning non-standard values from validateUserOp is misinterpreted by the EntryPoint as an aggregator address  |
| [PostOp Revert Exploitation](./postop_revert_exploitation)                 | When postOp reverts the paymaster loses its gas payment without receiving token compensation                    |

## Credits

These examples are developed and maintained by **[Trail of Bits](https://www.trailofbits.com/)**.

Contact us if you need help with smart contract security.
