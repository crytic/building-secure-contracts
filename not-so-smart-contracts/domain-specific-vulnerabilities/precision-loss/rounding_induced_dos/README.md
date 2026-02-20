# Rounding-Induced Denial of Service

Rounding up a computed value can cause it to exceed actual balances, reverting critical operations like withdrawals and position closures.

## Description

When a protocol rounds up a value for conservatism -- such as the token amount to return during a withdrawal -- the rounded amount can exceed the user's actual balance. The subsequent subtraction underflows and reverts, preventing the operation from completing.

An attacker can deliberately position themselves so that the rounded withdrawal amount barely exceeds their recorded balance, making their position impossible to close. This blocks time-sensitive operations and can trap funds permanently if no alternative exit path exists.

## Exploit Scenario

Bob has exactly 100 wei recorded in a staking contract. The unstake formula rounds up the amount to return, producing 101 wei. The subtraction `balances[bob] -= 101` reverts on underflow. Bob's position cannot be closed, and his funds are permanently trapped.

## Example

```solidity
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract VulnerableStaking {
    mapping(address => uint256) public balances;

    function unstake(address user, uint256 amount, uint256 exchangeRate) external {
        // Rounds up for "conservatism" -- but can exceed actual balance
        uint256 tokensToReturn = (amount * 1e18 + exchangeRate - 1) / exchangeRate;

        // Reverts if tokensToReturn > balances[user]
        balances[user] -= tokensToReturn;
    }
}
```

## Mitigations

- Cap rounded-up values to the actual available balance using `min()`.
- Ensure withdrawal and exit functions cannot revert due to rounding.
- Test with positions at exact boundary conditions.
- Implement partial withdrawal as a fallback.
