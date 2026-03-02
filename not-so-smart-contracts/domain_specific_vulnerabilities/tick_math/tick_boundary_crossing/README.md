# Tick Boundary Crossing

Incorrect tick iterator logic skips boundary ticks, causing liquidity accounting errors.

## Description

When a swap crosses a tick boundary in a Uniswap V3-style AMM, the pool must apply the net liquidity delta at that tick to update the active liquidity. Tick iteration logic starts from the current tick and searches for the next initialized tick in the direction of the swap. For zero-to-one direction swaps (price decreasing), the iterator conventionally starts searching from `currentTick` downward. If the implementation incorrectly initializes the search at `currentTick - 1`, it skips the current tick when the price is exactly at an initialized boundary.

When a boundary tick is skipped, its net liquidity delta is never applied to the active liquidity counter. The active liquidity diverges from the true sum of overlapping position liquidities. All subsequent swap output calculations and fee distributions use the wrong liquidity value. In pools with concentrated liquidity at specific ticks, this error compounds with each missed boundary crossing. In extreme cases, the active liquidity can underflow, causing reverts or allowing swaps that drain more tokens than the pool holds.

## Exploit Scenario

Alice and Bob both provide liquidity with overlapping ranges that share tick 1000 as a lower bound. A swap moves the price from tick 1001 to exactly tick 1000 in the zero-to-one direction. The iterator starts searching at tick 999, skipping tick 1000 entirely. The net liquidity delta at tick 1000 (which should remove Alice's and Bob's liquidity from the active set) is never applied. The pool reports a higher active liquidity than actually exists. Subsequent swaps in the one-to-zero direction compute excessive output amounts based on the inflated liquidity, allowing an arbitrageur to extract more tokens than the pool should provide.

## Example

```solidity
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract VulnerableTickIterator {
    mapping(int24 => int128) public tickNetLiquidity;
    mapping(int16 => uint256) public tickBitmap;

    function findNextInitializedTick(
        int24 currentTick,
        bool zeroForOne
    ) internal view returns (int24 nextTick) {
        if (zeroForOne) {
            // Vulnerable: subtracting 1 skips currentTick when price is exactly on it
            int24 searchStart = currentTick - 1;
            nextTick = _findNextBelow(searchStart);
        } else {
            nextTick = _findNextAbove(currentTick);
        }
    }

    function executeCrossing(int24 tick, bool zeroForOne) internal {
        int128 netDelta = tickNetLiquidity[tick];
        // This crossing is never reached for the skipped tick
        _updateActiveLiquidity(netDelta, zeroForOne);
    }

    function _findNextBelow(int24 tick) internal view returns (int24) { /* ... */ }
    function _findNextAbove(int24 tick) internal view returns (int24) { /* ... */ }
    function _updateActiveLiquidity(int128 delta, bool direction) internal { /* ... */ }
}
```

## Mitigations

- Process boundary ticks inclusively when the price lands exactly on an initialized tick.
- Verify that the tick iterator does not skip the current tick at boundaries in the zero-to-one direction.
- Test swap behavior when the price lands exactly on initialized ticks with concentrated liquidity.
- Compare active liquidity against the sum of all overlapping position liquidities as an invariant check after every swap.
