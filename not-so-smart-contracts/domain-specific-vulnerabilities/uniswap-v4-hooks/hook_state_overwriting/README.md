# Hook State Overwriting

Hooks that store pool state in non-keyed variables have their state overwritten when registered for additional pools.

## Description

A hook designed for a single pool may store its `PoolKey` or configuration in a plain state variable rather than a mapping keyed by `PoolId`. If anyone can call `PoolManager.initialize()` with the same hook address for a new pool, the hook's state is overwritten with the new pool's data. Existing users' funds and operations now reference the wrong pool. Withdrawals may route to the wrong pool, fee accounting breaks, and deposited liquidity becomes inaccessible through the hook's interface.

This issue is especially dangerous because `PoolManager.initialize()` is permissionless. Any address can create a new pool with any hook address, so a hook that does not guard against multi-pool registration or use per-pool storage is trivially exploitable by an attacker.

## Exploit Scenario

A custom accounting hook stores a single `poolKey` variable set during initialization. Alice deposits liquidity through the hook for Pool A. Bob calls `PoolManager.initialize()` with the same hook for Pool B. The hook's `poolKey` now points to Pool B. When Alice tries to withdraw, her operation targets Pool B instead of Pool A, and her liquidity in Pool A is stranded.

## Example

```solidity
contract VulnerableHook is BaseHook {
    PoolKey public poolKey;
    mapping(address => uint256) public deposits;

    function beforeInitialize(address, PoolKey calldata key, uint160, bytes calldata)
        external override returns (bytes4)
    {
        // BUG: overwrites state if called for a second pool
        poolKey = key;
        return this.beforeInitialize.selector;
    }

    function withdraw(uint256 amount) external {
        require(deposits[msg.sender] >= amount);
        deposits[msg.sender] -= amount;
        // Uses poolKey which may now point to a different pool
        poolManager.modifyLiquidity(poolKey, _withdrawParams(amount), "");
    }
}
```

## Mitigations

- Use `mapping(PoolId => PoolState)` for all per-pool data storage.
- Add an initialization guard (`require(!initialized)`) for single-pool hooks.
- Validate pool tokens and parameters in `beforeInitialize` to reject unexpected pools.
- Prevent unauthorized pool registration by checking caller identity or using an allowlist.
