# Unapplied Slippage Parameters

Slippage parameters that are validated but never forwarded to the actual swap provide false safety.

## Description

Code may accept and validate a slippage parameter at the entry point but fail to propagate it to the underlying swap or router call. This creates a false sense of security: the function signature suggests protection, but the actual execution uses a different value or zero. Common patterns include validating a `sellSlippage` parameter but passing a separately constructed struct with its own `minOut` field, or accepting `amountAMin` and `amountBMin` but hardcoding zeros in the router call.

The disconnect often arises from code refactoring, where slippage was added to the external interface but the internal plumbing was not updated. It can also occur when multiple layers of abstraction each define their own slippage field, and the outermost value never reaches the innermost call.

## Exploit Scenario

Alice calls `withdraw` with `sellSlippage` set to 2%. The function validates that 2% is within bounds, but the actual swap is routed through a `swapData` parameter with its own `minOut` set to 0. Alice's transaction is sandwiched and she loses 15%, despite believing she had 2% slippage protection.

## Example

```solidity
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract VulnerableUnappliedSlippage {
    uint256 public maxSlippage = 500; // 5%

    struct SwapData { address tokenIn; address tokenOut; uint256 amount; uint256 minOut; }

    function withdraw(uint256 amount, uint256 sellSlippage, SwapData calldata swapData) external {
        require(sellSlippage <= maxSlippage, "Slippage too high");
        // sellSlippage is validated but never used — swapData.minOut controls the swap
        router.swap(swapData.tokenIn, swapData.tokenOut, swapData.amount, swapData.minOut);
        IERC20(underlying).transfer(msg.sender, amount);
    }

    function addLiquidity(
        address tokenA, address tokenB, uint256 amtA, uint256 amtB,
        uint256 amountAMin, uint256 amountBMin // Accepted but ignored
    ) external {
        router.addLiquidity(tokenA, tokenB, amtA, amtB, 0, 0, msg.sender, block.timestamp);
    }
}
```

## Mitigations

- Trace slippage parameters through the entire call chain to verify they reach the swap.
- Write tests that deliberately sandwich-attack each function to confirm protection works.
- Avoid multiple representations of slippage in the same call flow.
- Assert that router calls use the validated slippage parameter, not a separate value.
