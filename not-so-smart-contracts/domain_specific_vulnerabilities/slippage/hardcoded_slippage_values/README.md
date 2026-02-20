# Hardcoded Slippage Values

Fixed slippage tolerances are either too tight, causing denial of service during volatility, or too loose, enabling extraction.

## Description

Hardcoded slippage percentages cannot adapt to changing market conditions. A tight tolerance (e.g., 1%) causes transactions to revert whenever normal price movement exceeds the threshold, effectively creating a denial-of-service condition during volatile periods. A loose tolerance (e.g., 50%) leaves users exposed to significant value extraction at all times.

Additionally, applying slippage arithmetic in the wrong direction can cause the protocol to accept worse rates than intended. For example, dividing by a slippage-reduced denominator inflates the acceptable output threshold, while multiplying by a slippage-reduced numerator deflates it. Choosing the wrong form means the "protection" allows more loss than the percentage suggests.

## Exploit Scenario

A protocol hardcodes 1% slippage for withdrawal swaps. During a volatile market event, all withdrawal transactions revert because the price moved more than 1%. Users cannot exit their positions for hours until volatility subsides. Meanwhile, a different protocol with 50% hardcoded slippage sees an MEV bot extract 40% of every swap during the same period.

## Example

```solidity
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract VulnerableHardcodedSlippage {
    uint256 constant SLIPPAGE = 5000; // 50% in basis points
    uint256 constant BASIS = 10000;

    function emergencySwap(address tokenIn, address tokenOut, uint256 amountIn) external {
        uint256 expectedOut = oracle.getPrice(tokenIn, tokenOut, amountIn);
        uint256 minOut = (expectedOut * (BASIS - SLIPPAGE)) / BASIS; // 50% tolerance
        router.swap(tokenIn, tokenOut, amountIn, minOut, msg.sender);
    }

    function invertedSlippage(uint256 amount, uint256 price) external {
        // Wrong direction: dividing by reduced price inflates acceptable amount
        uint256 minOut = (amount * 1e18) / ((price * (BASIS - SLIPPAGE)) / BASIS);
        router.swap(tokenA, tokenB, amount, minOut, msg.sender);
    }
}
```

## Mitigations

- Accept slippage as a user-provided parameter rather than a contract constant.
- Enforce minimum and maximum bounds on user-supplied slippage values.
- Verify that slippage is applied in the correct arithmetic direction.
- Allow governance to adjust default slippage bounds as market conditions change.
