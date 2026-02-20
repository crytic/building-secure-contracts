# Missing Tick Spacing Validation

Positions created with ticks not aligned to the pool's tick spacing revert or have zero liquidity.

## Description

Uniswap V3-style pools enforce that positions can only be created at ticks that are multiples of the pool's tick spacing. For example, a pool with tick spacing 60 only allows positions at ticks like -120, -60, 0, 60, 120, and so on. When a protocol builds on top of these pools and accepts user-provided or dynamically computed tick bounds without validating alignment, the resulting `mint` call either reverts deep in the pool contract or creates a position with zero effective liquidity.

This is especially problematic when tick values are computed dynamically. For instance, a TWAP value plus a fixed offset rarely produces a tick-spacing-aligned value. If the protocol does not round the computed ticks to the nearest valid multiple, every rebalance attempt will fail. Users who have deposited funds into such a vault will find their capital sitting idle, earning no fees, with no way to force a valid position placement.

## Exploit Scenario

A yield optimization vault computes position ranges by adding fixed offsets to the current TWAP tick. The TWAP returns tick 1003, and the vault sets `tickLower = 1003 - 500 = 503` and `tickUpper = 1003 + 500 = 1503`. The pool's tick spacing is 60, and neither 503 nor 1503 is a multiple of 60. The vault's `mint` call to the pool reverts. Users' deposits are stuck in the vault with no active position earning fees, and the vault cannot rebalance until someone manually intervenes with aligned tick values.

## Example

```solidity
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@uniswap/v3-core/contracts/interfaces/IUniswapV3Pool.sol";

contract VulnerableYieldVault {
    IUniswapV3Pool public pool;
    int24 public constant OFFSET = 500;

    function rebalance() external {
        int24 twapTick = _getTWAPTick(600);

        // Vulnerable: no alignment to tick spacing
        // If twapTick is 1003 and tickSpacing is 60,
        // tickLower = 503 and tickUpper = 1503 are not multiples of 60
        int24 tickLower = twapTick - OFFSET;
        int24 tickUpper = twapTick + OFFSET;

        // This call reverts inside the pool contract
        pool.mint(address(this), tickLower, tickUpper, _availableLiquidity(), "");
    }

    function _getTWAPTick(uint32 secondsAgo) internal view returns (int24) { /* ... */ }
    function _availableLiquidity() internal view returns (uint128) { /* ... */ }
}
```

## Mitigations

- Round tick values to the nearest valid multiple of tick spacing before use:
  ```solidity
  function roundToSpacing(int24 tick, int24 spacing) internal pure returns (int24) {
      return (tick / spacing) * spacing;
  }
  ```
- Validate alignment explicitly: `require(tickLower % tickSpacing == 0 && tickUpper % tickSpacing == 0)`.
- Use a helper that floors `tickLower` and ceils `tickUpper` to the nearest spacing boundary to ensure the range fully covers the intended price interval.
- Retrieve tick spacing from the pool contract rather than hardcoding it.
