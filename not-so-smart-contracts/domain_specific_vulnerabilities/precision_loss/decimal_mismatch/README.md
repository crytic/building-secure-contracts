# Decimal Mismatch

Assuming all tokens use 18 decimals causes massive over- or under-valuation when interacting with tokens of different precision.

## Description

ERC-20 tokens use varying decimal places: USDC and USDT use 6, WBTC uses 8, and most others use 18. When a protocol treats all token amounts as having 18 decimals, calculations involving lower-decimal tokens produce results that are off by orders of magnitude. A USDC amount of 1,000,000 (representing 1 USDC with 6 decimals) treated as an 18-decimal value represents an infinitesimal amount.

Conversely, a naive decimal conversion that divides before multiplying can truncate small amounts to zero. Both directions of error are exploitable: undervaluation lets attackers receive more output than they should, while overvaluation lets attackers extract excess value on withdrawal.

## Exploit Scenario

A DEX aggregator calculates token value using `amount * price / 1e8` without normalizing for token decimals. When comparing 1,000 USDC (1e9 raw, 6 decimals) against 1 ETH (1e18 raw, 18 decimals), the function returns values in incompatible scales -- 1e9 for USDC vs 1e18 for ETH. The aggregator treats both as equivalent precision, causing USDC to be undervalued by a factor of 1e12 relative to ETH.

## Example

```solidity
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract VulnerablePricing {
    function getValueInUSD(address token, uint256 amount, uint256 price) external view returns (uint256) {
        // Vulnerable: assumes all tokens have 18 decimals
        return amount * price / 1e8;
    }

    function convertAmount(uint256 amountIn, uint8 decimalsIn, uint8 decimalsOut) external pure returns (uint256) {
        // Vulnerable: when decimalsIn > decimalsOut, small amountIn values truncate to zero
        return amountIn * (10 ** decimalsOut) / (10 ** decimalsIn);
    }
}
```

## Mitigations

- Query and cache token decimals for all supported tokens.
- Normalize all amounts to a common precision before calculations.
- Multiply before dividing when scaling between decimal representations.
- Test every calculation path with 6, 8, and 18 decimal tokens.
