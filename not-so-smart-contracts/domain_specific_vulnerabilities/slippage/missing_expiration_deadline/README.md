# Missing Expiration Deadline

Transactions without deadlines can remain pending indefinitely and execute at unfavorable times.

## Description

When a swap transaction has no expiration deadline, or uses `block.timestamp` as the deadline, it can sit in the mempool for an arbitrary period. During this time, market conditions may change drastically. When the transaction finally executes--potentially hours or days later--the user receives a rate that was acceptable when submitted but is now unfavorable.

Using `block.timestamp` as a deadline is equivalent to having no deadline at all, because `block.timestamp` always equals the current time when the transaction is included in a block. A validator or MEV bot can hold the transaction and include it at any future time, and the deadline check will always pass.

## Exploit Scenario

Alice submits a swap with `block.timestamp` as the deadline during favorable market conditions. Network congestion delays her transaction for two hours. During that time, the output token drops 15% in value. When her transaction finally executes, she receives tokens at the original rate--15% above current market value. Alice effectively overpaid because no deadline prevented the stale execution.

## Example

```solidity
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract VulnerableNoDeadline {
    ISwapRouter public immutable router;

    function swapMaxDeadline(address tokenIn, address tokenOut, uint256 amount, uint256 minOut) external {
        router.exactInputSingle(ISwapRouter.ExactInputSingleParams({
            tokenIn: tokenIn, tokenOut: tokenOut, fee: 3000, recipient: msg.sender,
            deadline: type(uint256).max, // Never expires
            amountIn: amount, amountOutMinimum: minOut, sqrtPriceLimitX96: 0
        }));
    }

    function swapBlockTimestamp(address tokenIn, address tokenOut, uint256 amount, uint256 minOut) external {
        router.exactInputSingle(ISwapRouter.ExactInputSingleParams({
            tokenIn: tokenIn, tokenOut: tokenOut, fee: 3000, recipient: msg.sender,
            deadline: block.timestamp, // Always passes — equivalent to no deadline
            amountIn: amount, amountOutMinimum: minOut, sqrtPriceLimitX96: 0
        }));
    }
}
```

## Mitigations

- Accept a user-provided deadline parameter as an absolute timestamp.
- Validate that the deadline is in the future but not excessively far (e.g., maximum 30 minutes).
- Never use `block.timestamp` or `type(uint256).max` as deadlines.
- Include deadline checks in all swap and liquidity functions.
