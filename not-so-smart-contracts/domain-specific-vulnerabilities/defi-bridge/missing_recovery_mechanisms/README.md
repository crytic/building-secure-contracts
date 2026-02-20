# Missing Recovery Mechanisms

Absence of fund recovery paths causes permanent loss when bridge operations fail.

## Description

Bridge operations span multiple steps across separate chains. A typical flow involves locking tokens on the source chain, relaying a message, and executing an action (such as a swap or transfer) on the destination chain. When the destination-side execution fails, tokens may remain stuck in an intermediate contract with no way to return them to the user.

Failures can occur for many reasons: a swap reverts due to slippage, the receiver is a contract that cannot accept the token, gas is insufficient for execution, or a token is paused. Without an explicit recovery mechanism, these tokens become permanently inaccessible.

Similarly, when a bridge is paused for security reasons (e.g., in response to an exploit), in-flight transfers that have already been locked on the source chain but not yet released on the destination chain can be trapped indefinitely. Emergency withdrawal functions are essential to prevent this class of fund loss.

## Exploit Scenario

Alice bridges 10,000 USDC from Ethereum to Polygon with instructions to swap to DAI on arrival. The bridge locks her USDC on Ethereum and sends a cross-chain message. On Polygon, an executor contract receives the minted USDC and attempts the swap, but the transaction reverts due to high slippage. The USDC remains in the executor contract. Because there is no `claimFailedTransfer()` function and no mapping of the original sender, Alice's 10,000 USDC is permanently stuck.

## Example

```solidity
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

contract VulnerableExecutor {
    function executeWithSwap(
        address token,
        uint256 amount,
        address swapRouter,
        bytes calldata swapData,
        address recipient
    ) external {
        IERC20(token).transferFrom(msg.sender, address(this), amount);

        // Attempt the swap; if it fails, tokens are stuck
        (bool success, ) = swapRouter.call(swapData);

        if (success) {
            // Forward swapped tokens to recipient
        }

        // No fallback: if success == false, tokens remain
        // in this contract with no recovery path
    }
}
```

## Mitigations

- Implement a `claimFailedTransfer()` function that allows users to reclaim tokens from failed executions.
- Store the original sender address alongside each pending transfer so recovery can be routed correctly.
- Add emergency withdrawal functions with appropriate access controls for paused or stuck operations.
- Send tokens directly to the user as a fallback when destination-side execution fails, rather than leaving them in an intermediate contract.
