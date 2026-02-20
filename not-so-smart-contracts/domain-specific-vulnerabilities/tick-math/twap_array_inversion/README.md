# TWAP Array Inversion

Subtracting tick cumulatives in the wrong order inverts the TWAP price direction.

## Description

Uniswap V3's `observe()` function accepts an array of `secondsAgo` values and returns corresponding tick cumulatives. When called with `[secondsAgo, 0]`, index 0 contains the older observation and index 1 contains the most recent. The TWAP tick is computed as `(tickCumulatives[1] - tickCumulatives[0]) / timeElapsed`. If the indices are swapped, the subtraction produces the negation of the correct delta, inverting the price direction entirely.

A token that appreciated from tick 100 to tick 200 would be computed as having a TWAP delta of -100 instead of +100. The resulting negative tick translates to a price that moved in the opposite direction of reality. Any protocol relying on this inverted TWAP for pricing, liquidation decisions, or position management will act on fundamentally incorrect information. This error is particularly insidious because the code appears correct at a glance and produces plausible-looking values that are simply inverted in sign.

## Exploit Scenario

A liquidation bot uses a TWAP oracle with inverted array indices. Token A's price rises sharply over the observation window. The inverted TWAP reports a price drop of equal magnitude. The bot identifies Alice's long position as undercollateralized based on the falsely reported price decline and triggers a liquidation. Alice loses her healthy position to an unnecessary liquidation, and the liquidator profits from the discounted collateral.

## Example

```solidity
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@uniswap/v3-core/contracts/interfaces/IUniswapV3Pool.sol";

contract VulnerableTWAP {
    IUniswapV3Pool public pool;

    function getTWAPTick(uint32 secondsAgo) external view returns (int24 tick) {
        uint32[] memory secondsAgos = new uint32[](2);
        secondsAgos[0] = secondsAgo;
        secondsAgos[1] = 0;

        (int56[] memory tickCumulatives, ) = pool.observe(secondsAgos);

        // Vulnerable: indices are inverted
        // tickCumulatives[0] is the older value, tickCumulatives[1] is the newer value
        // This produces the negation of the correct delta
        int56 delta = tickCumulatives[0] - tickCumulatives[1];

        tick = int24(delta / int56(uint56(secondsAgo)));
    }
}
```

## Mitigations

- Follow the convention: `delta = tickCumulatives[1] - tickCumulatives[0]` where index 0 is older and index 1 is newer.
- Add assertions that verify the computed TWAP tick has the expected sign for known price movements in tests.
- Test with deterministic price scenarios where the expected TWAP direction is predetermined.
- Review the `secondsAgo` array ordering alongside the subtraction order to ensure consistency.
