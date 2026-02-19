# slot0 Tick Misalignment

Using `slot0.tick` instead of deriving the tick from `sqrtPriceX96` causes off-by-one errors at boundaries.

## Description

In Uniswap V3-style AMMs, `slot0` stores both the current `sqrtPriceX96` and the `tick`. However, the stored tick may not precisely correspond to the stored price at tick boundaries. After a swap that lands exactly on a tick boundary, the `slot0.tick` can be off by one relative to the tick derived from `sqrtPriceX96`. This discrepancy arises because the tick is updated based on crossing logic, not by recomputing it from the final price.

Protocols that read `slot0.tick` directly for position placement, range calculations, or limit-order logic produce incorrect results at these boundary conditions. The resulting off-by-one error shifts position ranges by one tick, causing asymmetric liquidity placement, reduced fee earnings, and increased impermanent loss. The correct approach is to always derive the tick from `sqrtPriceX96` using `TickMath.getTickAtSqrtRatio()` for any calculation where precision matters.

## Exploit Scenario

Alice deploys a liquidity management vault that reads `slot0.tick` to determine position ranges. After a large swap lands exactly on tick 1000, `slot0.tick` reports 999 due to the boundary crossing semantics. The vault uses this stale tick to compute a symmetric range of [949, 1049] instead of the intended [950, 1050]. Alice's depositors receive an asymmetric position that earns fewer fees and takes on more impermanent loss than the intended range. Bob, who monitors for this condition, places his own correctly-calculated position to capture the fees that Alice's vault misses.

## Example

```solidity
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@uniswap/v3-core/contracts/interfaces/IUniswapV3Pool.sol";

contract VulnerableVault {
    IUniswapV3Pool public pool;
    int24 public constant RANGE_WIDTH = 50;

    function rebalance() external {
        // Vulnerable: slot0.tick may be off-by-one at boundaries
        (uint160 sqrtPriceX96, int24 tick, , , , , ) = pool.slot0();

        // Using tick directly leads to misaligned ranges
        int24 tickLower = tick - RANGE_WIDTH;
        int24 tickUpper = tick + RANGE_WIDTH;

        _withdrawExistingPosition();
        _mintPosition(tickLower, tickUpper, sqrtPriceX96);
    }

    function _withdrawExistingPosition() internal { /* ... */ }
    function _mintPosition(int24 lower, int24 upper, uint160 price) internal { /* ... */ }
}
```

## Mitigations

- Derive the tick from `sqrtPriceX96` using `TickMath.getTickAtSqrtRatio()` for all critical calculations.
- Use `slot0.tick` only for display or non-critical informational purposes.
- Add boundary-condition tests that verify behavior when the price lands exactly on an initialized tick.
- Compare `slot0.tick` against the derived tick in monitoring systems to detect discrepancies.
