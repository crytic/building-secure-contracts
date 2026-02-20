# Cross-Chain Message Authentication Bypass

Missing validation of message source chain or sender allows forged cross-chain messages.

## Description

Cross-chain bridges receive messages through relayer interfaces such as `lzReceive()`, `ccipReceive()`, or `onMessageReceived()`. The receiving contract must validate two properties of every inbound message: that it originated from the expected source chain and that it was sent by the authorized sender contract on that chain.

When either check is missing, an attacker can forge messages that the bridge accepts as legitimate. For example, if the bridge validates the sender address but not the source chain ID, an attacker can deploy a contract at the same address on a different chain and send unauthorized messages. Conversely, if only the chain ID is validated, any contract on the expected chain can send messages.

Successful exploitation typically results in unauthorized minting of tokens on the destination chain or fraudulent withdrawal of locked funds, both without a corresponding deposit on the source chain.

## Exploit Scenario

A token bridge deployed on Ethereum expects messages only from its counterpart contract at address `0xBridge` on Arbitrum. Bob deploys a contract at address `0xBridge` on Optimism (using CREATE2 to match the address) and sends a crafted message to the Ethereum bridge. Because the bridge checks the sender address but not the source chain ID, Bob's message is accepted. The bridge mints tokens on Ethereum without any corresponding lock on Arbitrum.

## Example

```solidity
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract VulnerableBridgeReceiver {
    address public immutable lzEndpoint;
    address public trustedRemote;

    constructor(address _endpoint, address _trustedRemote) {
        lzEndpoint = _endpoint;
        trustedRemote = _trustedRemote;
    }

    function lzReceive(
        uint16 _srcChainId,
        bytes calldata _srcAddress,
        uint64 _nonce,
        bytes calldata _payload
    ) external {
        require(msg.sender == lzEndpoint, "Invalid endpoint");

        // Only checks sender address, not the source chain ID
        address srcAddr = abi.decode(_srcAddress, (address));
        require(srcAddr == trustedRemote, "Untrusted sender");

        (address to, uint256 amount) = abi.decode(_payload, (address, uint256));
        _mint(to, amount);
    }

    function _mint(address to, uint256 amount) internal {
        // Mint bridged tokens
    }
}
```

## Mitigations

- Validate both the source chain ID and the sender address for every inbound message.
- Store trusted remote addresses as a mapping of chain ID to address, and verify against it.
- Use framework-provided authentication mechanisms such as LayerZero's `trustedRemoteLookup` or Chainlink CCIP's `allowlistedSender` modifier.
- Reject messages from any chain ID that has not been explicitly registered.
