# Fee Truncation Bypass

Fees on small amounts truncate to zero, allowing users to avoid fees entirely by splitting operations.

## Description

When fees are calculated as `amount * feeBps / 10000`, any amount below `10000 / feeBps` produces a fee of zero due to integer truncation. An attacker can split a large operation into many small ones, each below the fee threshold, to avoid paying fees entirely. For a 0.1% fee (10 bps), any transfer of less than 1000 units pays no fee.

The cost of the attack is the gas for multiple transactions, which on low-cost chains can be far less than the fees avoided. On L2s and sidechains where gas costs fractions of a cent, even moderate fee rates become trivially bypassable through transaction splitting.

## Exploit Scenario

A protocol charges a 0.3% transfer fee (30 bps). Bob wants to transfer 1,000,000 tokens. Instead of one transfer (fee: 3,000 tokens), he splits into transfers of 333 tokens each. Each fee calculation: `333 * 30 / 10000 = 0`. Bob transfers his full amount fee-free across roughly 3,000 transactions.

## Example

```solidity
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract VulnerableFeeToken {
    uint256 public constant FEE_BPS = 30;
    mapping(address => uint256) public balances;
    address public feeCollector;

    function transfer(address to, uint256 amount) external {
        // Vulnerable: fee truncates to zero for small amounts
        uint256 fee = amount * FEE_BPS / 10000;
        balances[msg.sender] -= amount;
        balances[to] += amount - fee;
        balances[feeCollector] += fee;
    }
}
```

## Mitigations

- Round fees up using ceiling division: `(amount * feeBps + 9999) / 10000`.
- Enforce a minimum fee of 1 unit for any non-zero transfer.
- Accumulate fees on the total batch amount rather than per-operation.
- Consider whether the fee granularity matches the token's decimals.
