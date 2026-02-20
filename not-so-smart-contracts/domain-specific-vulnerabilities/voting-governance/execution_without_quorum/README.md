# Execution Without Quorum

Missing quorum validation allows proposals to pass with minimal voter participation.

## Description

Quorum is the minimum number of votes required for a governance decision to be valid. Without a quorum check, a proposal that receives a single "for" vote and zero "against" votes can be executed, even if the total governance token supply is millions. This allows a small minority to pass proposals without meaningful community participation.

The attack is especially effective during periods of low engagement or on recently launched protocols with concentrated token holdings. An attacker does not need a large token position; they only need to be the sole participant in a governance vote that lacks quorum enforcement.

## Exploit Scenario

A governance contract has 100 million total voting tokens. Bob holds 1 token. He creates a proposal to transfer the treasury (10 million USDC) to his address. During a holiday weekend when participation is low, only Bob votes "for" with his single token. The proposal passes the simple majority check (1 > 0) and is executed without any quorum requirement, draining the treasury.

## Example

```solidity
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract VulnerableGovernor {
    struct Proposal {
        uint256 forVotes;
        uint256 againstVotes;
        bool executed;
        address target;
        bytes callData;
        uint256 endBlock;
    }

    mapping(uint256 => Proposal) public proposals;

    function execute(uint256 proposalId) external {
        Proposal storage proposal = proposals[proposalId];
        require(block.number > proposal.endBlock, "Voting not ended");
        require(!proposal.executed, "Already executed");

        // Vulnerable: no quorum check, only simple majority
        require(proposal.forVotes > proposal.againstVotes, "Not passed");

        proposal.executed = true;
        (bool success, ) = proposal.target.call(proposal.callData);
        require(success, "Execution failed");
    }
}
```

## Mitigations

- Enforce a quorum requirement: `require(proposal.forVotes >= quorum())`.
- Calculate quorum as a percentage of total supply at the proposal snapshot block.
- Set quorum as an immutable parameter or make it governable with sufficient safeguards.
- Use `quorumNumerator / quorumDenominator * totalSupply` for a supply-relative calculation.
