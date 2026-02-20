# Unsafe Integer Downcast

Casting `int256` to `int24` without bounds checking causes tick values to wrap around.

## Description

Tick values in Uniswap V3-style AMMs are stored as `int24`, with a valid range of -887272 to 887272. Intermediate calculations often use `int256` for precision or to accommodate arithmetic that may temporarily exceed the `int24` range. When the result is cast to `int24` without validating that the value falls within the valid range, values outside the range silently wrap around due to two's complement truncation.

For example, a value of 887273 becomes -8388607 after truncation to `int24`, producing a completely incorrect tick that maps to a wildly different price. This class of bug is particularly dangerous because it does not revert. The contract continues executing with a nonsensical tick value, placing liquidity at extreme prices or computing incorrect swap outputs. The truncation is silent in both Solidity 0.7.x and 0.8.x when using explicit type casts.

## Exploit Scenario

A vault contract computes a target tick by adding a user-provided offset to the current tick using `int256` arithmetic. The current tick is 887200 and the offset is 100, producing a result of 887300 that exceeds `MAX_TICK` (887272). The contract casts this result to `int24`, producing -8388476 due to two's complement truncation. The vault creates a position at this nonsensical tick, placing liquidity at an extreme price where it will never earn fees. Bob, who supplied the offset, can then extract value from the mispriced position.

## Example

```solidity
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract VulnerableTickArithmetic {
    int24 public constant MAX_TICK = 887272;
    int24 public constant MIN_TICK = -887272;

    function computeTargetTick(
        int24 currentTick,
        int256 offset
    ) external pure returns (int24 targetTick) {
        int256 result = int256(currentTick) + offset;

        // Vulnerable: no bounds check before downcast
        // If result > MAX_TICK or result < MIN_TICK, the value wraps silently
        targetTick = int24(result);
    }

    function rebalance(int256 offset) external {
        int24 currentTick = _getCurrentTick();
        int24 target = this.computeTargetTick(currentTick, offset);

        // Position created at a wrapped, nonsensical tick
        _mintPosition(target - 100, target + 100);
    }

    function _getCurrentTick() internal view returns (int24) { /* ... */ }
    function _mintPosition(int24 lower, int24 upper) internal { /* ... */ }
}
```

## Mitigations

- Validate tick bounds before every downcast: `require(result >= MIN_TICK && result <= MAX_TICK)`.
- Use Uniswap's `TickMath.getSqrtRatioAtTick()` which includes built-in bounds checking.
- Use SafeCast libraries that revert on truncation for all integer downcasts.
- Add assertions after tick arithmetic to verify the result is within the valid range.
