# Fee Growth Underflow

Uniswap V3 fee growth arithmetic intentionally underflows, but reverts in Solidity 0.8+.

## Description

Uniswap V3 tracks fee growth using a relative accounting system where the fee growth "inside" a position is computed as `feeGrowthGlobal - feeGrowthBelow - feeGrowthAbove`. This subtraction is designed to underflow in `uint256` arithmetic, relying on modular (wrapping) arithmetic to produce correct results. The fee growth values are monotonically increasing counters, and the relative differences between snapshots yield the correct fee amounts regardless of whether intermediate subtractions underflow.

In Solidity versions prior to 0.8.0, this works because overflow and underflow are silent. In Solidity 0.8.0 and later, arithmetic operations revert on overflow and underflow by default. Protocols that fork Uniswap V3 code and compile with Solidity 0.8+ without wrapping fee growth calculations in `unchecked` blocks will experience transaction reverts during normal fee collection operations. This can permanently lock earned fees for all liquidity providers in affected pools.

## Exploit Scenario

Alice deploys a Uniswap V3 fork compiled with Solidity 0.8.17. Liquidity providers deposit funds and trading begins, accumulating fees across multiple ticks. When the first LP attempts to collect fees, the `feeGrowthInside` calculation subtracts `feeGrowthOutsideLower` from `feeGrowthGlobal`, which underflows because the outside value was snapshotted at a higher global counter. The transaction reverts. All fee collection is permanently blocked, and LPs cannot withdraw their earned fees.

## Example

```solidity
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract VulnerableFeeAccounting {
    struct TickInfo {
        uint256 feeGrowthOutside0X128;
        uint256 feeGrowthOutside1X128;
    }

    uint256 public feeGrowthGlobal0X128;
    mapping(int24 => TickInfo) public ticks;

    function getFeeGrowthInside(
        int24 tickLower,
        int24 tickUpper,
        int24 tickCurrent
    ) external view returns (uint256 feeGrowthInside0X128) {
        uint256 feeGrowthBelow0 = tickCurrent >= tickLower
            ? ticks[tickLower].feeGrowthOutside0X128
            : feeGrowthGlobal0X128 - ticks[tickLower].feeGrowthOutside0X128;

        uint256 feeGrowthAbove0 = tickCurrent < tickUpper
            ? ticks[tickUpper].feeGrowthOutside0X128
            : feeGrowthGlobal0X128 - ticks[tickUpper].feeGrowthOutside0X128;

        // Vulnerable: reverts on underflow in Solidity 0.8+
        feeGrowthInside0X128 = feeGrowthGlobal0X128 - feeGrowthBelow0 - feeGrowthAbove0;
    }
}
```

## Mitigations

- Wrap all fee growth arithmetic in `unchecked` blocks when using Solidity 0.8+.
- Audit all forked Uniswap V3 code for implicit underflow assumptions before changing compiler versions.
- Verify that fee collection works end-to-end in integration tests with multiple positions and tick crossings.
- Review the original Uniswap V3 source to identify every location that relies on wrapping arithmetic.
