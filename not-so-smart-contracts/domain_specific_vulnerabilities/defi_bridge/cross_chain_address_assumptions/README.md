# Cross-Chain Address Assumptions

Assuming the same address represents the same entity across chains leads to fund theft.

## Description

Account abstraction wallets such as Safe and ERC-4337 wallets derive their addresses from creation parameters including the factory address, initialization code, and salt. The same user may control different addresses on different chains because factory deployments, nonces, or initialization parameters differ. Conversely, different users may control the same address on different chains if they independently deploy contracts using CREATE2 with matching parameters.

Bridges that assume a given address is controlled by the same entity on every chain can send funds to unintended recipients. A user who bridges to "their own address" on a destination chain may lose funds to whoever controls that address there.

Additionally, on rollups like ZkSync, `msg.sender` is preserved for L1-to-L2 calls. This means a contract deployed at a specific address on L1 can impersonate any EOA on L2 that shares its address, enabling unauthorized actions on the destination chain.

## Exploit Scenario

Alice owns wallet `0xABC` on Ethereum, created via the Safe factory with her specific signing keys. She bridges 50 ETH to Arbitrum, specifying `0xABC` as the recipient. On Arbitrum, Bob has independently deployed a Safe wallet at `0xABC` using CREATE2 with different owners. Bob controls `0xABC` on Arbitrum and receives Alice's 50 ETH.

## Example

```solidity
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract VulnerableBridge {
    struct BridgeMessage {
        address token;
        uint256 amount;
        address receiver; // Same field used on source and destination
        uint16 srcChainId;
    }

    // Destination-side handler assumes receiver is the same entity
    function executeMessage(BridgeMessage calldata message) external {
        // No chain-specific address mapping or validation
        // Sends directly to the address from the source chain
        _releaseTokens(message.token, message.receiver, message.amount);
    }

    function _releaseTokens(
        address token,
        address receiver,
        uint256 amount
    ) internal {
        // Transfer tokens to receiver without verifying
        // that the same entity controls this address on this chain
        IERC20(token).transfer(receiver, amount);
    }
}
```

## Mitigations

- Allow users to specify different recipient addresses per destination chain instead of reusing the source address.
- Never assume that the same address is controlled by the same entity across chains.
- Apply address aliasing for L1-to-L2 calls, as implemented by Optimism, to prevent cross-domain impersonation.
- Warn users in the UI when bridging to smart contract addresses, as contract addresses are especially likely to differ across chains.
- Consider implementing a recipient registration mechanism on the destination chain.
