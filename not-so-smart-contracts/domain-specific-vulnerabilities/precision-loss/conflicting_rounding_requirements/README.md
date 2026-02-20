# Conflicting Rounding Requirements

Reusing a single intermediate value for calculations that need opposite rounding directions guarantees one of them is wrong.

## Description

When a calculated value serves multiple purposes -- such as determining both the fee owed and shares issued -- the rounding requirements conflict. Fee calculations should round up (user pays more), while share calculations should round down (user receives fewer). Using the same intermediate value for both means one direction is necessarily incorrect.

This is not always exploitable, but failure to recognize and document the conflict can lead to subtle economic exploits where the under-rounded path is repeatedly exercised. The cumulative loss compounds with each operation, and automated bots can extract value continuously.

## Exploit Scenario

A protocol normalizes a deposit amount once and uses it for both fee deduction (should round up) and share minting (should round down). The normalization rounds down. Alice repeatedly deposits minimum amounts, each time receiving slightly more shares than her fee payment warrants, gradually extracting value from the protocol.

## Example

```solidity
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract VulnerablePosition {
    uint256 public index;
    uint256 public totalSupply;
    uint256 public totalAssets;

    function processPosition(uint256 amount, uint256 feeRate) external view
        returns (uint256 fee, uint256 shares)
    {
        // Single normalization -- rounds down
        uint256 normalizedAmount = amount * index / 1e18;

        // Vulnerable: fee rounds down due to shared normalizedAmount (should round up)
        fee = normalizedAmount * feeRate / 1e18;

        // shares also use the same rounded-down normalizedAmount
        // The conflict: normalizedAmount should be rounded UP for fee, DOWN for shares
        shares = normalizedAmount * totalSupply / totalAssets;
    }
}
```

## Mitigations

- Calculate values separately when rounding requirements differ.
- Use `mulDivUp` for obligations and `mulDivDown` for entitlements.
- Document the intended rounding direction for each use of shared intermediate values.
- Audit all reuses of normalized or converted amounts.
