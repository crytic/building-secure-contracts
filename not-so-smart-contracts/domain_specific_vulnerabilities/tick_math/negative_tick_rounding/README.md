# Negative Tick Rounding

Solidity integer division truncates toward zero, producing incorrect TWAP ticks for negative values.

## Description

Solidity divides negative integers toward zero rather than toward negative infinity. When computing a time-weighted average tick from tick cumulatives, a negative delta divided by the time interval truncates upward instead of rounding down. For example, `-50 / 11` produces `-4` in Solidity, but the correct floored result is `-5`. This means the computed TWAP tick is consistently higher than the true average, resulting in an inflated price.

Protocols that use this TWAP for oracle pricing, liquidation thresholds, or position management systematically misjudge the actual price. The error magnitude is at most one tick, but even a single tick deviation can shift a price enough to prevent timely liquidations, alter swap routing decisions, or allow positions to remain open when they should be closed. Uniswap V3's own `OracleLibrary.consult()` includes a correction for this behavior, but protocols that implement TWAP calculation independently often omit it.

## Exploit Scenario

A lending protocol uses a Uniswap V3 TWAP oracle for collateral valuation. The token's average tick over the observation period is truly -455, but due to truncation toward zero, the protocol computes -454. This slightly higher tick translates to a higher price, making an undercollateralized position appear healthy. Bob exploits this by borrowing more than his collateral supports, leaving the protocol with bad debt when the position is eventually liquidated at the true, lower price.

## Example

```solidity
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@uniswap/v3-core/contracts/interfaces/IUniswapV3Pool.sol";

contract VulnerableTWAPOracle {
    IUniswapV3Pool public pool;

    function getTWAPTick(uint32 secondsAgo) external view returns (int24 tick) {
        uint32[] memory secondsAgos = new uint32[](2);
        secondsAgos[0] = secondsAgo;
        secondsAgos[1] = 0;

        (int56[] memory tickCumulatives, ) = pool.observe(secondsAgos);

        int56 tickCumulativesDelta = tickCumulatives[1] - tickCumulatives[0];

        // Vulnerable: truncates toward zero for negative values
        // -50 / 11 = -4 instead of the correct floored value -5
        tick = int24(tickCumulativesDelta / int56(uint56(secondsAgo)));
    }
}
```

## Mitigations

- Apply the Uniswap rounding correction after division:
  ```solidity
  if (tickCumulativesDelta < 0 && (tickCumulativesDelta % int56(uint56(secondsAgo)) != 0)) tick--;
  ```
- Use Uniswap's `OracleLibrary.consult()` which includes this correction.
- Test TWAP calculations with negative tick values that produce non-zero remainders.
- Validate TWAP results against known reference values in integration tests.
