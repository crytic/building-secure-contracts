# Native Token Handling Inconsistency

Different representations of native tokens across chains cause bridging failures or fund loss.

## Description

Native tokens such as ETH, AVAX, and MATIC have no standard representation across chains. Some protocols use `address(0)` to represent the native token, others use the sentinel address `0xEeeeeEeeeEeEeeEeEeEeeEEEeeeeEeeeeeeeEEeE`, and others wrap the native token into an ERC-20 (e.g., WETH). When a bridge uses one convention on the source chain and a different one on the destination chain, the mismatch causes failures.

If the destination contract receives a native token identifier and attempts to call ERC-20 functions such as `balanceOf()` or `transfer()` on it, the call reverts because the sentinel address or `address(0)` is not a contract. This leaves the user's funds locked on the source chain with no mechanism to complete or reverse the bridge operation.

The problem is compounded when the same asset is native on one chain (e.g., ETH on Ethereum) but exists as an ERC-20 on another (e.g., WETH on Polygon). Without explicit handling of these differences, balance accounting becomes corrupted and tokens can be permanently stranded.

## Exploit Scenario

Alice bridges native ETH from Ethereum to Arbitrum using a bridge that records deposits with the sentinel address `0xEeeeeEeeeEeEeeEeEeEeeEEEeeeeEeeeeeeeEEeE`. On the destination chain, the receiving contract calls `IERC20(0xEeeeeEeeeEeEeeEeEeEeeEEEeeeeEeeeeeeeEEeE).balanceOf(address(this))`, which reverts because the sentinel address is not a deployed contract on Arbitrum. Alice's ETH is locked on Ethereum with no way to complete or revert the bridge.

## Example

```solidity
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

contract VulnerableBridgeReceiver {
    // Sentinel used on the source chain
    address constant NATIVE_TOKEN = 0xEeeeeEeeeEeEeeEeEeEeeEEEeeeeEeeeeeeeEEeE;

    function executeMessage(
        address token,
        address recipient,
        uint256 amount
    ) external {
        // Fails when token is the native sentinel address:
        // address(0xEee...EEeE) has no code, so this reverts
        uint256 balance = IERC20(token).balanceOf(address(this));
        require(balance >= amount, "Insufficient balance");

        IERC20(token).transfer(recipient, amount);
    }
}
```

## Mitigations

- Define a canonical native token representation per chain and convert between representations at bridge boundaries.
- Wrap native tokens to their ERC-20 equivalent (e.g., WETH) immediately upon deposit.
- Include explicit token type metadata (native vs. ERC-20) in cross-chain messages.
- Handle native token and ERC-20 code paths separately with distinct logic for each.
