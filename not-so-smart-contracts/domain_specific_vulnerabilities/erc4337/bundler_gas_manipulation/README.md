# Bundler Gas Manipulation

Malicious bundlers can submit operations with insufficient gas, causing failures while still collecting payment.

## Description

A bundler controls the gas allocation for the entire bundle transaction. The ERC-4337 execution flow charges the user or paymaster for gas regardless of whether the inner call succeeds or fails. If the execution handler does not verify that the remaining gas exceeds the operation's `callGasLimit` before dispatching the inner call, the call will revert with an out-of-gas error.

The bundler exploits this by submitting a bundle transaction with just enough gas for the verification phase and post-operation accounting but not enough for the actual execution. The inner call fails, but the accounting logic still runs and charges the full gas cost. The bundler collects the gas payment difference between what was charged and what was actually consumed.

This attack is profitable when bundling multiple high-gas-limit operations together. The bundler intentionally starves each operation of gas, collecting payment for execution that never occurred.

## Exploit Scenario

A malicious bundler collects ten UserOperations, each specifying a `callGasLimit` of 500,000. The bundler submits the bundle with only enough gas for verification and accounting. All ten operations fail during execution due to insufficient gas. The bundler still receives gas compensation for each operation, profiting from the difference between charged and actual gas costs.

## Example

```solidity
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract VulnerableEntryPoint {
    function innerHandleOp(
        UserOperation calldata op,
        bytes calldata context,
        uint256 opIndex
    ) external {
        // No gas check before call
        // Missing: require(gasleft() >= op.callGasLimit + OVERHEAD)
        (bool success, ) = op.sender.call{gas: op.callGasLimit}(op.callData);

        // Post-op accounting runs regardless of success
        _postExecution(context, success, opIndex);
    }
}
```

## Mitigations

- Verify `gasleft() >= callGasLimit + overhead` before execution dispatch (verification gas has already been consumed at this point).
- Implement bundler reputation tracking that penalizes bundlers with high operation failure rates.
- Use trusted bundler allowlists for high-value operations.
- Monitor on-chain bundle success rates and blacklist consistently failing bundlers.
