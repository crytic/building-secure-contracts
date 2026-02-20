# Hook Reentrancy

Hooks that make external calls to user-controlled addresses create reentrancy vectors that allow state manipulation.

## Description

Hooks execute within the PoolManager's callback context and may make external calls to user-controlled addresses (such as arbitrary vault deposits or token callbacks). These external calls create reentrancy vectors that allow the caller to re-enter the hook's state-modifying functions before the original operation completes.

The PoolManager's `unlock` pattern is re-entrant by design, meaning hooks that rely on a single boolean lock cannot distinguish between legitimate nested calls and malicious re-entry. If a hook updates state (e.g., credits a balance) and then makes an external call before completing its accounting, the callee can re-enter and manipulate the intermediate state. Per-pool or per-operation guards are necessary to maintain safety.

## Exploit Scenario

A hook's `deposit` function credits `balances[msg.sender]` and then calls an external vault contract supplied by the user. The vault callback re-enters `deposit`, crediting the balance again before the first call's state is finalized. The attacker withdraws the double-credited balance, draining the hook's funds.

## Example

```solidity
contract VulnerableHook is BaseHook {
    mapping(address => uint256) public balances;

    function deposit(address vault, uint256 amount) external {
        // State updated before external call
        balances[msg.sender] += amount;

        // BUG: user-controlled vault address creates reentrancy vector
        // Attacker's vault can re-enter deposit() before this call returns
        ERC4626(vault).deposit(amount, address(this));
    }

    function withdraw(uint256 amount) external {
        require(balances[msg.sender] >= amount);
        balances[msg.sender] -= amount;
        IERC20(token).transfer(msg.sender, amount);
    }
}
```

## Mitigations

- Use OpenZeppelin's `ReentrancyGuard` or per-pool reentrancy guards on all state-modifying functions.
- Follow the checks-effects-interactions pattern: complete all state updates before making external calls.
- Whitelist external call targets such as vaults and tokens rather than accepting arbitrary addresses.
- Avoid making external calls to user-supplied addresses within hook callbacks.
