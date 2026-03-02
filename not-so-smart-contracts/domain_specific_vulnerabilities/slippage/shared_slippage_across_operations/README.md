# Shared Slippage Across Operations

Reusing a single slippage value for multiple operations with different characteristics leads to insufficient protection.

## Description

When the same slippage tolerance or `minAmountOut` is applied to multiple operations--such as both legs of a cross-chain swap, multi-hop swaps through different pools, or operations involving tokens with different decimals--one or more of those operations will have incorrect protection. Each operation has distinct pool depths, fee structures, and token characteristics that demand independent slippage parameters.

A slippage tolerance appropriate for a deep USDC/ETH pool may be dangerously loose for a shallow long-tail token pool. Similarly, applying the same raw `minOut` value to an 18-decimal token and a 6-decimal token will either over-constrain one or under-protect the other.

## Exploit Scenario

A bridge uses a single `slippageTol` for both the source-chain swap (USDC to bridged token) and the destination-chain swap (bridged token to USDT). The source pool is deep and handles the slippage well, but the destination pool is shallow. An MEV bot exploits the shared tolerance on the destination chain, extracting value that exceeds what the user intended to risk.

## Example

```solidity
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract VulnerableSharedSlippage {
    function xcall(
        address tokenIn, address tokenOut, uint256 amount, uint256 slippageTol
    ) external {
        // Same tolerance for two very different pools
        uint256 localAmount = swapToLocal(tokenIn, amount, slippageTol);
        bridge.send(localAmount, tokenOut, slippageTol);
    }

    function openPositions(
        address tokenA, // 18 decimals
        address tokenB, // 6 decimals
        uint256 amountA, uint256 amountB, uint256 minOut
    ) external {
        // Same minOut for tokens with wildly different decimal scales
        router.swap(tokenA, weth, amountA, minOut);
        router.swap(tokenB, weth, amountB, minOut);
    }
}
```

## Mitigations

- Accept separate slippage parameters for each swap operation.
- Calculate per-operation minimums based on each pool's depth and fee structure.
- Handle token decimal differences when deriving slippage bounds.
- For cross-chain operations, allow independent source and destination slippage tolerances.
