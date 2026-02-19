# Delegation Power Manipulation

Incorrect delegation accounting creates, duplicates, or destroys voting power.

## Description

Token-based governance systems allow holders to delegate their voting power to other addresses. The delegation mechanism must correctly transfer voting power from the old delegate to the new delegate while maintaining the invariant that total voting power equals total token supply.

Common bugs include: self-delegation doubling voting power (counted as both holder and delegate), missing checkpoint updates when changing delegates (voting power lost), and circular delegation chains creating infinite loops in power calculation. Each of these breaks the fundamental invariant of the governance system and can be exploited to gain disproportionate influence or deny others their rightful voting power.

## Exploit Scenario

Alice holds 1000 tokens with default self-delegation. She delegates to Bob. The contract adds 1000 to Bob's voting power but does not subtract from Alice's checkpoint because the self-delegation was implicit and not tracked. Alice still shows 1000 voting power from her last checkpoint, and Bob also has 1000 voting power. 2000 total votes exist for 1000 tokens.

## Example

```solidity
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract VulnerableVotes {
    mapping(address => uint256) public balances;
    mapping(address => address) public delegates;
    mapping(address => uint256) public votingPower;

    function delegate(address delegatee) external {
        address oldDelegate = delegates[msg.sender];
        delegates[msg.sender] = delegatee;

        // Vulnerable: does not update old delegate's voting power
        // when old delegate was implicit self-delegation (address(0))
        if (oldDelegate != address(0)) {
            votingPower[oldDelegate] -= balances[msg.sender];
        }
        // Missing: subtract from self if oldDelegate == address(0)

        votingPower[delegatee] += balances[msg.sender];
    }

    function getVotes(address account) external view returns (uint256) {
        // Returns checkpoint voting power without verifying invariant
        return votingPower[account];
    }
}
```

## Mitigations

- Update checkpoints for both the old and new delegate on every delegation change.
- Explicitly track self-delegation state rather than relying on implicit defaults.
- Add an invariant test: `sum(getVotes(delegate)) == totalSupply()`.
- Detect and prevent circular delegation chains.
- Use OpenZeppelin's `ERC20Votes` which handles delegation correctly.
