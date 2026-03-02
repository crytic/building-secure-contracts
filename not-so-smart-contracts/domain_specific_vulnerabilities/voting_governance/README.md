# (Not So) Smart Contracts (Voting Governance)

This section contains examples of common vulnerability patterns found in on-chain governance and voting systems. These issues arise from incorrect vote accounting, missing temporal protections, and flawed delegation logic that allow attackers to manipulate governance outcomes.

## Features

Each not-so-smart-contract includes:

- Description of the vulnerability type
- Attack scenarios to exploit the vulnerability
- Solidity code examples demonstrating the flaw
- Recommendations to eliminate or mitigate the vulnerability

## Vulnerabilities

| Name                                                             | Description                                                                    |
| ---------------------------------------------------------------- | ------------------------------------------------------------------------------ |
| [Flash Loan Voting](./flash_loan_voting)                         | Using current token balance for voting power allows flash loan-funded attacks  |
| [Double Voting](./double_voting)                                 | Missing vote tracking allows the same account to vote multiple times           |
| [Execution Without Quorum](./execution_without_quorum)           | Missing quorum validation allows proposals to pass with minimal participation  |
| [Timelock Bypass](./timelock_bypass)                             | Missing or zero-value timelock delays allow immediate proposal execution       |
| [Snapshot Timing Manipulation](./snapshot_timing_manipulation)   | Same-block snapshots enable vote power front-running                           |
| [Delegation Power Manipulation](./delegation_power_manipulation) | Incorrect delegation accounting creates or duplicates voting power             |
| [Retroactive Parameter Changes](./retroactive_parameter_changes) | Modifying governance parameters affects active proposals                       |
| [Vote After Transfer](./vote_after_transfer)                     | Transferring tokens after voting allows the same tokens to vote multiple times |

## Credits

These examples are developed and maintained by **[Trail of Bits](https://www.trailofbits.com/)**.

Contact us if you need help with smart contract security.
