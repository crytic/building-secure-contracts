# On-Chain Slippage Calculation

Computing slippage bounds from on-chain state at execution time provides no protection because the state is already manipulated.

## Description

Some contracts compute the minimum acceptable output by querying a quoter or reading pool reserves at execution time, then applying a percentage tolerance. This provides zero protection because an attacker who frontruns the transaction has already altered the on-chain state before the slippage calculation runs. The quoter returns the manipulated price, and the tolerance is applied to an already-bad baseline.

The minimum output effectively tracks the manipulated price rather than the fair market price. A 5% slippage tolerance computed on-chain provides no real protection because the check measures deviation from the attacker's already-manipulated price rather than from the pre-attack market price.

## Exploit Scenario

A protocol calls `quoteExactInputSingle` on-chain to determine the expected output, then allows 5% slippage from that quote. Bob frontruns Alice's transaction, moving the price down 30%. The on-chain quote now returns the manipulated price, and Alice's 5% tolerance is measured from the already-depressed value. Alice loses approximately 30% instead of the intended 5% maximum.

## Example

```solidity
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract VulnerableOnChainSlippage {
    IQuoter public immutable quoter;
    ISwapRouter public immutable router;

    function swap(address tokenIn, address tokenOut, uint256 amountIn) external {
        // Queried at execution time — already reflects attacker's manipulation
        uint256 expectedOut = quoter.quoteExactInputSingle(tokenIn, tokenOut, 3000, amountIn, 0);
        uint256 minOut = (expectedOut * 95) / 100;

        ISwapRouter.ExactInputSingleParams memory params = ISwapRouter.ExactInputSingleParams({
            tokenIn: tokenIn,
            tokenOut: tokenOut,
            fee: 3000,
            recipient: msg.sender,
            deadline: block.timestamp,
            amountIn: amountIn,
            amountOutMinimum: minOut,
            sqrtPriceLimitX96: 0
        });
        router.exactInputSingle(params);
    }
}
```

## Mitigations

- Compute minimum output off-chain using current market data and pass it as a function parameter.
- Never query on-chain prices to derive slippage bounds within the same transaction as the swap.
- Use TWAP oracles if on-chain bounds are strictly necessary, as they resist single-block manipulation.
- Treat any on-chain spot price as attacker-controlled when designing slippage checks.
