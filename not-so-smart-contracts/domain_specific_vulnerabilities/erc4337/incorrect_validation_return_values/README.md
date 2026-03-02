# Incorrect Validation Return Values

Returning values other than 0 or 1 from validateUserOp is misinterpreted by the EntryPoint as an aggregator address.

## Description

The ERC-4337 specification requires `validateUserOp` to return a packed `uint256` where the first 20 bytes (least significant 160 bits) are interpreted as an aggregator address. A return value of `0` means validation succeeded with no aggregator, and `SIG_VALIDATION_FAILED` (1) means the signature is invalid. Any other value in the lower 160 bits is treated as a valid aggregator contract address.

When a multisig wallet implementation returns the count of missing signatures (e.g., 2 or 3) instead of mapping failures to `SIG_VALIDATION_FAILED`, the EntryPoint interprets this as an aggregator at a low address such as `0x0000...0002`. If that address has no code or is a precompile, the aggregator validation call will likely revert or return unexpected data during ABI decoding. In either case, the behavior is undefined and bypasses the intended multisig validation logic.

## Exploit Scenario

A 3-of-5 multisig wallet receives only 1 valid signature and returns `2` (the number of missing signers) from `validateUserOp`. The EntryPoint interprets `2` as aggregator address `0x0000...0002`, which is the SHA-256 precompile. Since this address does not implement the `IAggregator` interface, the call to `validateSignatures` produces undefined behavior -- it may revert, return garbage data, or fail ABI decoding. The intended multisig validation is completely bypassed.

## Example

```solidity
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract VulnerableMultisig {
    uint256 public required;
    mapping(address => bool) public isOwner;

    function _validateSignature(
        UserOperation calldata userOp,
        bytes32 userOpHash
    ) internal view returns (uint256 validationData) {
        bytes[] memory sigs = abi.decode(userOp.signature, (bytes[]));
        uint256 remaining = required;

        for (uint256 i = 0; i < sigs.length; i++) {
            address signer = ECDSA.recover(userOpHash, sigs[i]);
            if (isOwner[signer]) remaining--;
        }

        // Bug: returns remaining count instead of 0 or SIG_VALIDATION_FAILED
        return remaining;
    }
}
```

## Mitigations

- Always return exactly `0` for success or `SIG_VALIDATION_FAILED` (1) for failure.
- Map any non-zero remaining signer count to `SIG_VALIDATION_FAILED`.
- Pack `validAfter` and `validUntil` timestamps correctly in the upper bits of the return value.
- Add explicit tests for edge cases with 0, 1, and more than 1 missing signatures.
