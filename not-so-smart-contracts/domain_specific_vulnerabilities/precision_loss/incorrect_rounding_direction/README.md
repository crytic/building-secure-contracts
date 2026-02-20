# Incorrect Rounding Direction

Rounding in a direction that favors users over the protocol enables value extraction through repeated operations.

## Description

In protocols that convert between tokens and shares, the rounding direction determines who absorbs the precision loss. When rounding favors the user -- for example, rounding up when minting shares or rounding down when calculating fees -- each operation leaks a small amount of value from the protocol. An attacker can amplify this by performing many small operations, each extracting the rounding error.

Over time or through automation, this drains protocol reserves. The correct convention is to always round against the user: round down when the user receives value, round up when the user pays.

## Exploit Scenario

A vault rounds share minting up: a deposit of 1 wei mints 1 share instead of 0. Alice deposits 1 wei repeatedly in 1000 transactions, accumulating 1000 shares. She redeems all shares at once for more tokens than she deposited, extracting the rounding difference each time.

## Example

```solidity
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract VulnerableVault {
    uint256 public totalShares;
    uint256 public totalAssets;

    function calculateFee(uint256 amount, uint256 feeBps) external pure returns (uint256) {
        // Vulnerable: truncates to zero for small amounts, user pays no fee
        return amount * feeBps / 10000;
    }

    function deposit(uint256 assets) external returns (uint256 shares) {
        // Vulnerable: rounding up gives user MORE shares than warranted
        shares = mulWadUp(assets, totalShares, totalAssets);
        totalShares += shares;
        totalAssets += assets;
    }

    function mulWadUp(uint256 x, uint256 y, uint256 d) internal pure returns (uint256) {
        return (x * y + d - 1) / d; // Rounds up -- favors the depositor
    }
}
```

## Mitigations

- Round down when users receive tokens or shares.
- Round up when users pay fees or provide value to the protocol.
- Use explicit rounding functions (`mulDivUp`, `mulDivDown`).
- Document the intended rounding direction for every calculation.
