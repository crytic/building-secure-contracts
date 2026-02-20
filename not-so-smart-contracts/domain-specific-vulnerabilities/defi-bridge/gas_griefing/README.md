# Gas Griefing

Insufficient gas forwarding causes permanent message channel blockage.

## Description

Cross-chain messaging protocols such as LayerZero require sufficient gas on the destination chain to execute the received message payload. The gas limit for destination execution is typically specified by the caller at send time. If the bridge hardcodes a gas limit that is too low, or allows users to specify an arbitrary gas amount without enforcing a minimum, the destination-side execution will run out of gas.

In protocols that use an ordered message queue, such as LayerZero v1, a failed message blocks the entire channel. All subsequent messages sent to the same bridge on the destination chain are queued behind the failed message and cannot be processed until the failed message is retried with sufficient gas. This creates a denial-of-service condition that affects all users of the bridge.

An attacker can exploit this intentionally by sending a single message with an insufficient gas parameter, halting all bridge operations on the affected pathway until the blocked message is manually resolved.

## Exploit Scenario

Bob calls the bridge function with `dstGasForCall` set to an extremely low value. The message is relayed to the destination chain, where LayerZero attempts to deliver it. The execution runs out of gas, and LayerZero stores the failed message in its blocking queue. All subsequent bridge messages from the source chain to this destination contract are blocked. Bridge operations remain halted until someone retries the stored message with adequate gas, which may require manual intervention.

## Example

```solidity
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract VulnerableBridgeSender {
    address public immutable lzEndpoint;

    constructor(address _endpoint) {
        lzEndpoint = _endpoint;
    }

    function bridgeTokens(
        uint16 dstChainId,
        address to,
        uint256 amount,
        uint256 dstGasForCall // User-controlled, no minimum enforced
    ) external payable {
        bytes memory payload = abi.encode(to, amount);

        // No minimum gas validation: attacker can set dstGasForCall to 0
        bytes memory adapterParams = abi.encodePacked(
            uint16(2),
            uint256(dstGasForCall), // Insufficient gas blocks the channel
            uint256(0),
            address(0)
        );

        ILayerZeroEndpoint(lzEndpoint).send{value: msg.value}(
            dstChainId,
            abi.encodePacked(address(this)),
            payload,
            payable(msg.sender),
            address(0),
            adapterParams
        );
    }
}
```

## Mitigations

- Set chain-specific minimum gas limits and reject any send request that specifies less than the minimum.
- Validate user-provided gas parameters against empirically determined minimums for each destination chain and payload type.
- Use LayerZero v2 or other non-blocking message patterns that do not halt the channel on execution failure.
- Implement gas estimation with safety margins rather than relying on user-specified or hardcoded values.
- Add an administrative function to retry or clear blocked messages.
