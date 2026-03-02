# Delta Sign Convention Errors

Misinterpreting the sign convention for swap deltas and hook deltas causes payments to flow in the wrong direction.

## Description

Uniswap V4 uses a sign convention from the swapper's perspective: positive deltas mean the swapper receives tokens (the hook gives), and negative deltas mean the swapper pays tokens (the hook takes). For the `afterSwap` return value (`int128`), returning a positive value means the hook is giving tokens to the swapper, not collecting. Misinterpreting this convention -- for example, using a positive value when intending to charge a fee -- results in the hook paying the user instead of collecting. The error compounds when swap direction (`zeroForOne`) is not accounted for, as the roles of `token0` and `token1` as input/output switch depending on the direction.

An incorrect sign in a high-volume pool leaks value continuously. Because each individual swap may only lose a small amount, the bug can go undetected for days while the hook's token balance is steadily drained by every user who swaps through the pool.

## Exploit Scenario

A hook intends to charge a 500-token fee by returning a delta of `+500`. Under V4 conventions, positive means the hook gives tokens to the caller. Instead of collecting a fee, the hook pays 500 tokens per swap to the user. Every swap drains the hook's balance until it is empty.

## Example

```solidity
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract VulnerableHook is BaseHook {
    function afterSwap(address, PoolKey calldata, IPoolManager.SwapParams calldata, BalanceDelta, bytes calldata)
        external override returns (bytes4, int128)
    {
        // BUG: positive delta means hook GIVES tokens to caller
        // To charge a fee, this should be negative
        int128 feeDelta = 500 * 1e18;

        // Hook pays the user 500 tokens instead of collecting
        return (this.afterSwap.selector, feeDelta);
    }
}
```

## Mitigations

- Follow the convention from the swapper's perspective: negative delta = swapper pays (hook takes), positive delta = swapper receives (hook gives).
- Account for swap direction (`zeroForOne`) when determining which token is input vs output.
- Test both swap directions with explicit fee balance assertions after each swap.
- Verify all deltas sum to zero at transaction end using PoolManager settlement checks.
