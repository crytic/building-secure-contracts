# Ratio Truncation to Zero

When a ratio in a formula truncates to zero, the formula can collapse to return the entire pool balance to the attacker.

## Description

AMM and pool formulas often compute ratios of the form `balanceIn / (balanceIn + amountIn)`. When `balanceIn` is extremely small relative to `amountIn`, this ratio truncates to zero. If the formula then computes output as `balanceOut * (1 - ratio)`, a zero ratio means the output equals the full `balanceOut` -- the attacker receives everything.

This typically requires the attacker to first drain one side of the pool to a minimal balance (e.g., 1 wei) using a flash loan, then exploit the truncation on the return swap. The combination of pool manipulation and precision loss can extract the entire value of the opposite token.

## Exploit Scenario

A pool holds 1 wei of Token A and 10,000 Token B. Bob swaps a large amount of Token A. The ratio `1 / (1 + largeAmount)` truncates to 0, so the formula returns `balanceOut * (1 - 0)` = all 10,000 Token B. Bob drains the pool entirely.

## Example

```solidity
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract VulnerablePool {
    uint256 public balanceA;
    uint256 public balanceB;

    function swap(uint256 tokenIn) external returns (uint256 tokenOut) {
        // Vulnerable: ratio truncates to zero when balanceA << tokenIn
        uint256 ratio = balanceA * 1e18 / (balanceA + tokenIn);
        tokenOut = balanceB * (1e18 - ratio) / 1e18;

        balanceA += tokenIn;
        balanceB -= tokenOut;
    }
}
```

## Mitigations

- Round ratios up to prevent truncation to zero.
- Enforce minimum pool balance requirements.
- Use higher-precision intermediate representations.
- Consider flash-loan-based attacks when analyzing ratio calculations.
