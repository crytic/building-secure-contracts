# Division Before Multiplication

Performing division before multiplication causes intermediate truncation that can reduce results to zero.

## Description

Solidity has no floating-point types, so integer division truncates toward zero. When a division precedes a multiplication in an arithmetic expression, the intermediate quotient loses precision. If the numerator is smaller than the denominator, the intermediate result truncates to zero and all subsequent multiplications produce zero.

This commonly occurs in reward calculations, share conversions, and exchange rate computations where the ordering of operations is not carefully controlled. Rewriting `(a / b) * c` as `(a * c) / b` preserves precision by keeping the numerator large before the final division.

## Exploit Scenario

A reward distribution contract calculates user rewards as `(userBalance / totalSupply) * rewardPool`. When `userBalance` is 100 and `totalSupply` is 1e18, the division produces 0, and the user receives no reward despite being entitled to a proportional share.

## Example

```solidity
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract VulnerableRewards {
    uint256 public totalSupply;
    mapping(address => uint256) public balances;

    function calculateReward(address user, uint256 rate, uint256 period) external view returns (uint256) {
        // Vulnerable: division before multiplication truncates to zero for small balances
        return (balances[user] / 1e18) * rate * period;
    }

    function convertToShares(uint256 assets, uint256 supply, uint256 totalAssets) external pure returns (uint256) {
        // Vulnerable: assets < totalAssets produces zero shares
        return (assets / totalAssets) * supply;
    }
}
```

## Mitigations

- Multiply before dividing: `(amount * rate * period) / 1e18`.
- Use `mulDiv` libraries for overflow-safe multiply-then-divide operations.
- Test with minimum possible input values (1 wei).
- Review all arithmetic sequences for division-before-multiplication patterns.
