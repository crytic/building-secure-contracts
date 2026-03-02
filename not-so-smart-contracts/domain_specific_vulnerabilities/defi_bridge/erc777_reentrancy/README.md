# ERC-777 Reentrancy

ERC-777 token callbacks enable reentrancy in balance-difference accounting.

## Description

Many bridge contracts calculate deposit amounts using a balance-difference pattern. The contract records its token balance before a `transferFrom`, executes the transfer, then measures the balance again. The difference is credited as the deposited amount. This pattern is designed to handle fee-on-transfer tokens correctly.

ERC-777 tokens implement hooks that are called during transfers. Specifically, the `tokensToSend` hook is invoked on the sender before tokens are moved. An attacker can use this hook to reenter the deposit function during the `transferFrom` call, before the first deposit's balance measurement completes.

When reentrancy occurs, both the outer and inner calls record the same `balanceBefore` value. Each call then independently calculates the balance difference, resulting in the attacker being credited for the same tokens multiple times. This effectively doubles (or further multiplies) the attacker's recorded deposit without requiring additional token transfers.

## Exploit Scenario

Bob calls `deposit()` on the bridge with an ERC-777 token. The bridge records `balanceBefore`. During `transferFrom`, the ERC-777 `tokensToSend` hook triggers a callback to Bob's contract. Bob reenters `deposit()`, which records a new `balanceBefore` (identical to the first, since the first transfer has not yet settled). Both calls independently compute the balance difference after their respective transfers complete, and Bob is credited twice for the same underlying tokens.

## Example

```solidity
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

contract VulnerableBridgeDeposit {
    mapping(address => mapping(address => uint256)) public deposits;

    // No reentrancy guard
    function deposit(address token, uint256 amount, uint16 dstChainId) external {
        uint256 balanceBefore = IERC20(token).balanceOf(address(this));

        // ERC-777 tokensToSend hook fires here, enabling reentrancy
        IERC20(token).transferFrom(msg.sender, address(this), amount);

        uint256 balanceAfter = IERC20(token).balanceOf(address(this));
        uint256 actualAmount = balanceAfter - balanceBefore;

        deposits[msg.sender][token] += actualAmount;

        _sendCrossChainMessage(dstChainId, msg.sender, token, actualAmount);
    }

    function _sendCrossChainMessage(
        uint16 dstChainId,
        address sender,
        address token,
        uint256 amount
    ) internal {
        // Send cross-chain message
    }
}
```

## Mitigations

- Add a reentrancy guard (e.g., OpenZeppelin's `ReentrancyGuard`) to all deposit and withdrawal functions.
- Follow the Checks-Effects-Interactions pattern by updating state before making external calls.
- Update deposit accounting before executing the token transfer.
- Consider restricting supported tokens to known standards and explicitly blocking ERC-777 tokens if their hooks are not needed.
