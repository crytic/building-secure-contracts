# Unchecked Return Values

Silent failures from unchecked low-level calls cause fund loss.

## Description

Bridge contracts frequently use low-level `.call()` to transfer native tokens to recipients. Unlike `transfer()` or `send()`, a failed `.call()` does not automatically revert the transaction. Instead, it returns a boolean `false`, and execution continues normally. If the return value is not checked, the bridge marks the transfer as complete even though the recipient never received the funds.

This commonly occurs when the recipient is a smart contract that lacks a `receive()` or `fallback()` function, or when the recipient contract's receive function reverts. The native tokens remain in the bridge contract, but the accounting records the transfer as successful.

Over time, this leads to an accumulation of orphaned native tokens in the bridge contract with no mechanism to identify their rightful owners or redistribute them. The affected users have no recourse because the bridge considers their transfers complete.

## Exploit Scenario

Alice bridges tokens to a smart contract wallet on the destination chain. The bridge unwraps WETH and sends native ETH via `receiver.call{value: amount}("")`. Alice's smart contract wallet does not implement a `receive()` function, so the call returns `false`. The bridge ignores the return value and emits a `TransferCompleted` event. Alice's transfer is marked as finalized, but the ETH remains in the bridge contract with no way for Alice to claim it.

## Example

```solidity
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract VulnerableBridgeWithdrawal {
    mapping(bytes32 => bool) public processedTransfers;

    function executeWithdrawal(
        bytes32 transferId,
        address payable receiver,
        uint256 amount
    ) external {
        require(!processedTransfers[transferId], "Already processed");
        processedTransfers[transferId] = true;

        // Return value is not checked: if receiver cannot accept
        // ETH, the call fails silently and funds remain here
        receiver.call{value: amount}("");

        emit TransferCompleted(transferId, receiver, amount);
    }

    event TransferCompleted(bytes32 transferId, address receiver, uint256 amount);
}
```

## Mitigations

- Always check the return value of low-level `.call()` and revert on failure.
- Use OpenZeppelin's `Address.sendValue()`, which reverts automatically on failed transfers.
- Implement a pull-based withdrawal pattern as a fallback, allowing users to claim funds if the push transfer fails.
- Revert the entire transaction on failed native token transfers to prevent accounting inconsistencies.
