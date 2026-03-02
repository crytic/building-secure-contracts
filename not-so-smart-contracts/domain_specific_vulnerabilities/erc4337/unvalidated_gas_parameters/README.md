# Unvalidated Gas Parameters in Paymaster

Paymasters that accept arbitrary gas values allow attackers to drain deposits in a single operation.

## Description

The ERC-4337 EntryPoint charges the paymaster based on gas parameters specified in the UserOperation: `preVerificationGas`, `callGasLimit`, and `verificationGasLimit`. These values determine the maximum gas cost that will be deducted from the paymaster's deposit. If the paymaster's validation function does not bound these values, an attacker can set them to extreme amounts.

The EntryPoint preflight locks the maximum possible gas cost from the paymaster's deposit. While `callGasLimit` is charged based on actual usage, `preVerificationGas` is added directly to the charged cost without metering. An attacker who also operates as their own bundler can craft an operation with inflated `preVerificationGas`, have the paymaster sponsor it, and collect the excess payment. Additionally, locking excessive gas amounts can DoS the paymaster by exhausting its deposit for other operations.

## Exploit Scenario

An attacker creates a UserOperation with `callGasLimit` set to 30 million and `preVerificationGas` set to 10 million. The verifying paymaster checks the signature but does not validate gas parameters. The EntryPoint charges the full gas cost from the paymaster's deposit. The attacker, acting as their own bundler, submits the operation and receives the inflated gas payment, draining the paymaster's deposit.

## Example

```solidity
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract VulnerablePaymaster is BasePaymaster {
    address public verifyingSigner;

    function _validatePaymasterUserOp(
        UserOperation calldata userOp,
        bytes32 userOpHash,
        uint256 maxCost
    ) internal view override returns (bytes memory context, uint256 validationData) {
        bytes32 hash = getHash(userOp);
        address signer = ECDSA.recover(hash, userOp.paymasterAndData[20:]);
        require(signer == verifyingSigner, "invalid signature");

        // No gas parameter validation
        // Missing: bounds checks on callGasLimit, verificationGasLimit, preVerificationGas
        return (abi.encode(userOp.sender), 0);
    }
}
```

## Mitigations

- Validate all gas parameters against maximum thresholds in `validatePaymasterUserOp`.
- Cap the total operation cost (`maxCost`) to a configurable limit per operation.
- Include gas parameter bounds in the paymaster's off-chain signature to prevent tampering.
- Implement per-operation and per-account spending limits.
