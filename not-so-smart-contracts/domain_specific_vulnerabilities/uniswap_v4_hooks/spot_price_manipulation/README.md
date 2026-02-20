# Spot Price Manipulation in Hooks

Using the current spot price for calculations within hooks allows price manipulation attacks within a single transaction.

## Description

Hooks that read the current pool price via `getSlot0()` for fee calculations, incentive distributions, or access control decisions are vulnerable to intra-transaction price manipulation. In Uniswap V4's singleton architecture with transient delta accounting, moving the price within a single transaction is cheap because no actual token transfers occur until settlement. An attacker can manipulate the price, trigger the hook's price-dependent logic at the manipulated value, and restore the price -- all in one transaction with minimal capital.

This is fundamentally different from V3 price manipulation, where each swap requires actual token transfers. V4's deferred settlement makes the capital cost of price manipulation approach zero within the `unlock` callback, as long as the price is restored before settlement. Any hook that trusts `slot0` as a reliable price reference is exploitable.

## Exploit Scenario

A hook calculates dynamic fees based on the current `sqrtPriceX96` from `slot0`, charging lower fees when the price is within a target range. Bob manipulates the pool price into the low-fee range within a single unlock callback (near-free with delta accounting), triggers a large swap that the hook processes at the reduced fee, then restores the price. Bob pays a fraction of the intended fees.

## Example

```solidity
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract VulnerableHook is BaseHook {
    function beforeSwap(address, PoolKey calldata key, IPoolManager.SwapParams calldata, bytes calldata)
        external override returns (bytes4, BeforeSwapDelta, uint24)
    {
        // Vulnerable: slot0 price is manipulable within a single transaction
        (uint160 sqrtPriceX96,,,) = poolManager.getSlot0(key.toId());

        uint24 fee;
        if (sqrtPriceX96 > STABLE_LOWER && sqrtPriceX96 < STABLE_UPPER) {
            fee = 100;  // 0.01% fee in "stable" range
        } else {
            fee = 3000; // 0.3% fee otherwise
        }

        return (this.beforeSwap.selector, BeforeSwapDeltaLibrary.ZERO_DELTA, fee);
    }
}
```

## Mitigations

- Use TWAP oracles instead of spot prices for price-sensitive calculations.
- Cache the beginning-of-block price and use it throughout the block.
- Apply time-weighted fee mechanisms that cannot be manipulated within a single block.
- Never use `slot0` price directly for economic decisions in hooks.
