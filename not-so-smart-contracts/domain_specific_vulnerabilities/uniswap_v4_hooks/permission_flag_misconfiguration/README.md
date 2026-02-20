# Hook Permission Flag Misconfiguration

Incorrect hook permission flags cause return deltas to be silently ignored, breaking fee collection and settlement.

## Description

Hook permissions in Uniswap V4 are encoded in the contract's deployment address through bitwise flags. If a hook returns a non-zero delta from `afterSwap` but the `afterSwapReturnDelta` flag is not set, the PoolManager silently ignores the delta. The hook's accounting assumes tokens were transferred, but no actual settlement occurs. This creates a mismatch between the hook's internal state and the PoolManager's delta accounting, leading to `CurrencyNotSettled` errors or complete fee bypass.

Since permissions are derived from the contract address, they are immutable after deployment. A misconfigured permission flag cannot be corrected without redeploying the hook to a new address with the correct bit pattern. The silent nature of the failure makes this particularly dangerous: the hook appears to execute correctly, but its economic effects are nullified.

## Exploit Scenario

A fee-collecting hook returns a delta in `afterSwap` to charge a 0.1% fee. However, the `afterSwapReturnDelta` permission flag was not set during deployment. Every swap executes without the fee being collected, and the hook's internal fee accounting diverges from reality. The protocol loses all fee revenue while believing it is operating correctly.

## Example

```solidity
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract VulnerableHook is BaseHook {
    uint256 public collectedFees;

    function getHookPermissions() public pure override returns (Hooks.Permissions memory) {
        return Hooks.Permissions({
            beforeSwap: false,
            afterSwap: true,
            afterSwapReturnDelta: false, // BUG: delta will be silently ignored
            // ... other flags
            beforeAddLiquidity: false,
            afterAddLiquidity: false
        });
    }

    function afterSwap(address, PoolKey calldata, IPoolManager.SwapParams calldata params, BalanceDelta, bytes calldata)
        external override returns (bytes4, int128)
    {
        int128 feeAmount = int128(params.amountSpecified / 1000);
        collectedFees += uint128(feeAmount);
        // This delta is silently ignored because afterSwapReturnDelta is false
        return (this.afterSwap.selector, feeAmount);
    }
}
```

## Mitigations

- Verify all `returnDelta` permission flags match actual return behavior before deployment.
- Call `Hooks.validateHookPermissions` in the constructor to catch mismatches early.
- Test with both zero and non-zero delta returns and assert on actual settlement amounts.
- Audit the deployment script to confirm the address encodes the correct permission bits.
