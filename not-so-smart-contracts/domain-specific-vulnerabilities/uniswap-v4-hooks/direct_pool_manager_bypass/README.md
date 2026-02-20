# Direct PoolManager Bypass

Users can bypass hook enforcement by calling PoolManager directly, circumventing hook-imposed restrictions.

## Description

Hooks cannot prevent users from interacting with the PoolManager directly. If a hook tracks state in `beforeAddLiquidity` or `beforeSwap` (such as entry timestamps for JIT penalties, or whitelist checks), users can skip the hook by calling `PoolManager.modifyLiquidity()` or `PoolManager.swap()` without routing through the hook's wrapper contract. The hook's callback still fires, but any state the hook expected to have been set by an earlier wrapper call will be missing.

This breaks any hook logic that depends on multi-step state initialization across a wrapper function and a callback. The fundamental issue is that hooks are reactive (triggered by PoolManager) rather than gatekeeping (controlling access to PoolManager). Any security invariant that depends on users entering through a specific contract path is bypassable.

## Exploit Scenario

A hook imposes a JIT penalty by recording LP entry timestamps in a wrapper function called `addLiquidity`. Bob adds liquidity directly through the PoolManager's `unlock` callback, bypassing the timestamp recording. When Bob removes liquidity through the hook, no penalty is applied because his entry time was never set, and the default value of zero causes the time check to pass trivially.

## Example

```solidity
contract VulnerableHook is BaseHook {
    mapping(address => uint256) public lpEntryTime;

    // Wrapper function that users are expected to call
    function addLiquidity(PoolKey calldata key, uint256 amount) external {
        lpEntryTime[msg.sender] = block.timestamp;
        // ... calls poolManager.modifyLiquidity()
    }

    function beforeRemoveLiquidity(address sender, PoolKey calldata, IPoolManager.ModifyLiquidityParams calldata, bytes calldata)
        external override returns (bytes4)
    {
        // Bypass: lpEntryTime[sender] is 0 if user added liquidity directly
        uint256 timeHeld = block.timestamp - lpEntryTime[sender];
        if (timeHeld < 1 hours) {
            revert("JIT penalty period");
        }
        return this.beforeRemoveLiquidity.selector;
    }
}
```

## Mitigations

- Validate state consistency in removal/exit hooks by requiring entry time to be non-zero.
- Implement all critical checks in the hook callback itself, not in external wrapper functions.
- Track liquidity positions within hook callbacks (`beforeAddLiquidity` / `afterAddLiquidity`) rather than wrapper calls.
- Consider whether the hook's security model survives direct PoolManager interaction.
