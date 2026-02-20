# Cross-Chain Operation Replay

Missing chain identifier in signature hashes allows replaying signed operations on other chains.

## Description

When `chainId` is not included in the paymaster or wallet signature hash, the same signed UserOperation can be submitted on any chain where the smart account is deployed at the same address. Multi-chain deployments using deterministic CREATE2 addresses are especially vulnerable because the account exists at an identical address across all supported chains.

The attacker does not need any special access. They only need to observe a valid signed operation on one chain and resubmit it on another. Since the hash is identical on both chains, the signature recovers to the same owner address, and the operation passes validation. The nonce may also match if the account was recently deployed on the target chain and has not been used.

This vulnerability affects both account-level signature validation and paymaster sponsorship signatures. A paymaster that sponsors gas on one chain can have its deposit drained on another chain where it also operates.

## Exploit Scenario

Alice signs a UserOperation on Ethereum mainnet that transfers 10 USDC to a merchant. Bob observes this operation and replays it on Arbitrum, where Alice has the same smart account address deployed via CREATE2. Because `chainId` was not part of the signature hash, the operation validates successfully on Arbitrum. Alice loses 10 USDC on Arbitrum in addition to the intended payment on mainnet.

## Example

```solidity
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract VulnerableAccount {
    function getHash(UserOperation calldata userOp) public pure returns (bytes32) {
        // Missing: block.chainid and address(this) are not included
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

- Include `block.chainid` in all signature hashes for both accounts and paymasters.
- Include the contract address (`address(this)`) in the hash to bind it to a specific deployment.
- Maintain per-chain nonce tracking to prevent replay even if the hash is compromised.
- Use EIP-712 structured signing with a domain separator that includes the chain ID.
