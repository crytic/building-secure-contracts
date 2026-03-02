# Slippage Check at Wrong Stage

Verifying slippage before fees or against intermediate values instead of the final output renders the check ineffective.

## Description

Slippage protection must be applied to the final value the user receives after all deductions. When the check occurs before fees are applied, the user may pass the slippage check but receive significantly less after fee deduction. Similarly, in multi-step operations, checking slippage against an intermediate result (e.g., after the first swap in a two-swap route) leaves the subsequent steps unprotected.

The gap between the slippage check and the final output creates an exploitable window. An attacker can manipulate the unprotected portion of the transaction, and the earlier slippage check provides no defense because it has already passed.

## Exploit Scenario

A protocol's sell function checks that the raw swap output meets the minimum threshold, then applies a 5% fee. Alice sets her minimum to 95 tokens, the swap returns 96 tokens (passes the check), but after the 5% fee she receives only 91.2 tokens--below her intended minimum. An MEV bot exploits the gap between the check and the fee deduction.

## Example

```solidity
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract VulnerableWrongStageCheck {
    uint256 public feeRate = 500; // 5% in basis points (out of 10000)

    function sellAllAmount(
        address tokenIn, address tokenOut, uint256 amount, uint256 minFillAmount
    ) external {
        uint256 fillAmt = performSwap(tokenIn, tokenOut, amount);

        // Slippage check BEFORE fee — user receives less than minFillAmount
        require(fillAmt >= minFillAmount, "Slippage exceeded");

        fillAmt = (fillAmt * (10000 - feeRate)) / 10000; // Fee applied after check
        IERC20(tokenOut).transfer(msg.sender, fillAmt);
    }

    function swapMultiHop(
        address tokenA, address tokenB, address tokenC,
        uint256 amount, uint256 minOut
    ) external {
        uint256 intermediate = router.swap(tokenA, tokenB, amount, 0);
        require(intermediate >= minOut, "Slippage exceeded"); // Checks intermediate, not final
        uint256 finalOut = router.swap(tokenB, tokenC, intermediate, 0);
        IERC20(tokenC).transfer(msg.sender, finalOut);
    }
}
```

## Mitigations

- Apply all fees and deductions before checking slippage against the user's minimum.
- In multi-step operations, verify the final output amount, not intermediate values.
- Ensure token wrapping, unwrapping, and bridging fees are all accounted for before the check.
- Consider using a balance-difference pattern: record the user's balance before and after, then compare the net change to the minimum.
