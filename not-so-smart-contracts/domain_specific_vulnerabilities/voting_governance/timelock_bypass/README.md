# Timelock Bypass

Missing or zero-value timelock delays allow immediate proposal execution.

## Description

Timelocks enforce a mandatory delay between a proposal passing and its execution, giving token holders time to react to malicious proposals (for example, by exiting the protocol or mobilizing opposition). If the timelock delay can be set to zero, or if the execution function does not validate that the delay has elapsed, proposals can be executed immediately after passing.

This eliminates the security window that timelocks are designed to provide, converting governance attacks from detectable to instantaneous. A compromised admin or a successful governance proposal can reduce the delay to zero, effectively disabling the safety mechanism for all future executions.

## Exploit Scenario

A governance system uses a timelock with a configurable delay. The admin (a compromised multisig) sets the delay to zero. Bob then creates a proposal to upgrade the token contract to a malicious implementation. The proposal passes governance voting, is queued with a zero delay, and is immediately executed. Token holders have no time to exit or respond.

## Example

```solidity
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract VulnerableTimelock {
    address public admin;
    uint256 public delay;

    struct QueuedTx {
        address target;
        bytes callData;
        uint256 eta;
        bool executed;
    }

    mapping(bytes32 => QueuedTx) public queuedTransactions;

    // Vulnerable: no minimum delay enforced
    function setDelay(uint256 newDelay) external {
        require(msg.sender == admin, "Not admin");
        delay = newDelay;
    }

    function execute(bytes32 txHash) external {
        QueuedTx storage txn = queuedTransactions[txHash];
        // Vulnerable: if delay is 0, eta is in the past immediately
        require(block.timestamp >= txn.eta, "Not ready");
        require(!txn.executed, "Already executed");

        txn.executed = true;
        (bool success, ) = txn.target.call(txn.callData);
        require(success, "Execution failed");
    }
}
```

## Mitigations

- Enforce a minimum delay: `require(newDelay >= MINIMUM_DELAY)`.
- Make `MINIMUM_DELAY` an immutable constant (e.g., 2 days).
- Validate `block.timestamp >= proposal.eta` before execution.
- Require delay changes to go through governance with the current delay applied.
