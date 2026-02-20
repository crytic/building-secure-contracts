# Dynamic Fee Misconfiguration

Missing the dynamic fee flag in pool configuration or failing to initialize fees after pool creation silently disables fee collection.

## Description

Uniswap V4 pools that use hook-controlled dynamic fees require the `DYNAMIC_FEE_FLAG` to be set in the pool key's fee field. If this flag is omitted, the pool treats the fee field as a static fee value and ignores the hook's fee updates via `updateDynamicLPFee()`. Similarly, if the hook does not call `poolManager.updateDynamicLPFee()` in `afterInitialize`, the pool starts with a zero fee until the first update is triggered.

In both cases, swaps execute without collecting the intended LP fees, causing permanent revenue loss. The pool appears to function normally -- swaps succeed, liquidity can be added and removed -- making the misconfiguration difficult to detect without explicit fee monitoring. The error is especially common when copying deployment scripts between static-fee and dynamic-fee pool configurations.

## Exploit Scenario

A protocol deploys a dynamic fee hook but sets the pool key's fee field to `3000` instead of `LPFeeLibrary.DYNAMIC_FEE_FLAG`. The pool initializes with a static 0.3% fee. The hook calls `updateDynamicLPFee()` to adjust fees based on volatility, but the updates are silently ignored. During high-volatility periods, LPs earn far less than the intended dynamic fee, and arbitrageurs extract value that should have been captured as fees.

## Example

```solidity
contract VulnerableDeployer {
    function deployPool(IPoolManager poolManager, address hookAddr) external {
        PoolKey memory key = PoolKey({
            currency0: currency0,
            currency1: currency1,
            // BUG: should be LPFeeLibrary.DYNAMIC_FEE_FLAG for dynamic fees
            fee: 3000,
            tickSpacing: 60,
            hooks: IHooks(hookAddr)
        });
        poolManager.initialize(key, SQRT_PRICE_1_1);
    }
}

contract VulnerableHook is BaseHook {
    function afterInitialize(address, PoolKey calldata, uint160, int24, bytes calldata)
        external override returns (bytes4)
    {
        // BUG: does not call updateDynamicLPFee() to set initial fee
        return this.afterInitialize.selector;
    }
}
```

## Mitigations

- Always set `LPFeeLibrary.DYNAMIC_FEE_FLAG` in the pool key fee field for dynamic fee pools.
- Call `updateDynamicLPFee` in `afterInitialize` to set the initial fee immediately.
- Add deployment tests that verify the fee flag is set correctly and the initial fee is non-zero.
- Monitor fee collection in production to detect silent misconfiguration.
