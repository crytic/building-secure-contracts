# Retroactive Parameter Changes

Modifying governance parameters affects active proposals.

## Description

Governance systems have configurable parameters: voting period, quorum, proposal threshold, and timelock delay. When these parameters are stored as mutable global state and applied dynamically to all proposals, changing them affects proposals that are already in progress.

An attacker who controls parameter changes (either directly or through a prior governance vote) can manipulate the outcome of active proposals by increasing quorum to make them fail, reducing the voting period to cut off remaining voters, or lowering the proposal threshold to enable spam. This retroactive application of new rules to existing proposals violates the expectation that proposals are governed by the rules in effect when they were created.

## Exploit Scenario

A contentious proposal is close to reaching quorum with 45% participation. The admin calls `setQuorum(60%)` during the voting period. The previously near-passing proposal now falls well below the new 60% quorum requirement and fails. The proposing community had no opportunity to adjust to the new rules.

## Example

```solidity
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract VulnerableGovernor {
    address public admin;
    uint256 public quorumPercent;
    uint256 public totalSupply;

    struct Proposal {
        uint256 forVotes;
        uint256 againstVotes;
        uint256 endBlock;
        bool executed;
    }

    mapping(uint256 => Proposal) public proposals;

    // Vulnerable: takes effect immediately, including for active proposals
    function setQuorum(uint256 newQuorumPercent) external {
        require(msg.sender == admin, "Not admin");
        quorumPercent = newQuorumPercent;
    }

    function execute(uint256 proposalId) external {
        Proposal storage proposal = proposals[proposalId];
        require(block.number > proposal.endBlock, "Voting not ended");

        // Vulnerable: reads current quorum, not the quorum at proposal creation
        uint256 quorum = (totalSupply * quorumPercent) / 100;
        require(proposal.forVotes >= quorum, "Quorum not met");
        require(proposal.forVotes > proposal.againstVotes, "Not passed");

        proposal.executed = true;
    }
}
```

## Mitigations

- Snapshot all governance parameters at proposal creation time.
- Store parameters per-proposal: `proposal.quorum = quorum()` at creation.
- Apply parameter changes only to future proposals.
- Require parameter changes to go through governance with a timelock delay.
