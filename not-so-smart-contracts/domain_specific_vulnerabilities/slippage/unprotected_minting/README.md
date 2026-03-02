# Unprotected Share Minting

Minting shares or LP tokens based on manipulable on-chain reserves without minimum output checks enables donation attacks.

## Description

Vault deposits and liquidity additions that compute shares from current reserves are effectively swaps and need slippage protection. An attacker can inflate the reserve balance (via direct token transfer or flash loan) before the victim's deposit, causing the share calculation to return fewer shares than expected. Without a `minShares` parameter, the victim has no way to reject an unfavorable rate.

The same pattern applies to LP token minting where `amountAMin` and `amountBMin` are zero. Any operation that converts a known input quantity into a variable number of output tokens based on manipulable on-chain state requires a minimum output check.

## Exploit Scenario

A vault has 100 shares and 100 tokens. Bob, who holds 50 of those shares, frontruns Alice's 10-token deposit by donating 1000 tokens to the vault. The vault now has 1100 tokens for 100 shares. Alice's 10 tokens mint only 0 shares (10 _ 100 / 1100 = 0 due to integer truncation). Bob redeems his 50 shares, receiving 555 tokens (50 _ 1110 / 100), recovering his donation plus Alice's deposit.

## Example

```solidity
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract VulnerableVault {
    IERC20 public asset;
    uint256 public totalShares;

    mapping(address => uint256) public shares;

    function mint(uint256 depositAmount) external {
        // Share calculation uses manipulable totalAssets
        uint256 totalAssets = asset.balanceOf(address(this));
        uint256 newShares = (totalShares == 0)
            ? depositAmount
            : (depositAmount * totalShares) / totalAssets;

        // No minShares check — attacker can inflate totalAssets to mint 0 shares
        shares[msg.sender] += newShares;
        totalShares += newShares;
        asset.transferFrom(msg.sender, address(this), depositAmount);
    }

    function addLiquidityAndStake(uint256 amountA, uint256 amountB) external {
        router.addLiquidity(tokenA, tokenB, amountA, amountB, 0, 0, address(this), block.timestamp);
        stakingPool.stake(lpToken.balanceOf(address(this)));
    }
}
```

## Mitigations

- Require a user-provided `minShares` parameter for all deposit operations.
- Implement first-depositor protections such as a virtual offset or minimum initial deposit.
- Use ERC-4626 inflation attack mitigations (virtual shares and assets).
- Require minimum LP token output for all liquidity additions.
