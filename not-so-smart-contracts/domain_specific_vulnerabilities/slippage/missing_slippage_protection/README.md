# Missing Slippage Protection

Swap and liquidity operations that accept any output amount expose users to unlimited sandwich attack losses.

## Description

When `amountOutMinimum` is hardcoded to 0 or no minimum output parameter exists, the transaction accepts any exchange rate. MEV bots detect these transactions in the mempool, frontrun to move the price unfavorably, let the victim's swap execute at the worse rate, then backrun to restore the price. The victim receives far fewer tokens than the market rate warrants.

The same pattern applies to liquidity additions where `amountAMin` and `amountBMin` are set to zero. Any on-chain operation that converts one asset to another is effectively a swap and requires a minimum output constraint. Without it, the entire output value is extractable by a sandwich attacker.

## Exploit Scenario

Alice calls a protocol's swap function that internally sets `amountOutMinimum` to 0. An MEV bot frontruns her transaction, pushing the price of her output token up by 20%. Alice's swap executes at the inflated price. The bot immediately sells, extracting Alice's 20% loss as profit.

## Example

```solidity
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract VulnerableSwapper {
    ISwapRouter public immutable router;

    function swapTokens(address tokenIn, address tokenOut, uint256 amount) external {
        ISwapRouter.ExactInputSingleParams memory params = ISwapRouter.ExactInputSingleParams({
            tokenIn: tokenIn,
            tokenOut: tokenOut,
            fee: 3000,
            recipient: msg.sender,
            deadline: block.timestamp,
            amountIn: amount,
            amountOutMinimum: 0, // No slippage protection
            sqrtPriceLimitX96: 0
        });
        router.exactInputSingle(params);
    }

    function addLiquidity(address tokenA, address tokenB, uint256 amtA, uint256 amtB) external {
        IRouter(router).addLiquidity(tokenA, tokenB, amtA, amtB, 0, 0, msg.sender, block.timestamp);
    }
}
```

## Mitigations

- Require a user-provided `minAmountOut` parameter on all swap-like operations.
- Reject operations where `minAmountOut` is zero.
- Apply slippage protection to all liquidity additions and removals.
- Never hardcode minimum output values inside the contract.
