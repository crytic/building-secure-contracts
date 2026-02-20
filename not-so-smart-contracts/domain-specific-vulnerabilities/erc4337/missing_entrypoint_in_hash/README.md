# Missing EntryPoint in Operation Hash

Omitting the EntryPoint address from the user operation hash enables replay across EntryPoint upgrades.

## Description

ERC-4337 requires the userOpHash to include the EntryPoint address so that signatures are bound to a specific EntryPoint deployment. When the account's `getHash` function omits the EntryPoint address, the resulting hash depends only on the operation fields themselves.

If the protocol upgrades to a new EntryPoint contract, all outstanding signed operations remain valid because none of the hashed fields changed. An attacker who observed or stored a previously signed operation can resubmit it against the new EntryPoint. The signature verification passes, and the operation executes a second time with identical calldata.

This breaks the fundamental assumption that upgrading the EntryPoint invalidates all outstanding signatures. The risk is compounded when combined with missing `chainId` in the hash, as the same operation could be replayed across both EntryPoint versions and chains simultaneously.

## Exploit Scenario

Alice signs a user operation that transfers 5 ETH through her smart account on EntryPoint v0.6. The protocol upgrades to EntryPoint v0.7. An attacker takes Alice's previously signed operation and submits it to the new EntryPoint. Because the hash did not include the EntryPoint address, the signature is still valid. The new EntryPoint executes the operation, transferring another 5 ETH from Alice's account.

## Example

```solidity
contract VulnerableAccount {
    function getHash(UserOperation calldata userOp) public pure returns (bytes32) {
        // Missing: address(entryPoint) is not included in the hash
        return keccak256(abi.encode(
            userOp.sender,
            userOp.nonce,
            keccak256(userOp.initCode),
            keccak256(userOp.callData),
            userOp.callGasLimit,
            userOp.verificationGasLimit,
            userOp.preVerificationGas,
            userOp.maxFeePerGas,
            userOp.maxPriorityFeePerGas,
            keccak256(userOp.paymasterAndData)
        ));
    }
}
```

## Mitigations

- Include `address(entryPoint)` in the user operation hash.
- Include `block.chainid` alongside the EntryPoint address.
- Use an EIP-712 domain separator that binds the EntryPoint address as the verifying contract.
- Invalidate old signatures explicitly when migrating to a new EntryPoint.
