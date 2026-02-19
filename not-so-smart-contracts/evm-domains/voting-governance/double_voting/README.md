# Double Voting

Missing vote tracking allows the same account to vote multiple times on a proposal.

## Description

Governance contracts must record which accounts have voted on each proposal and reject subsequent vote attempts. If the contract omits the `hasVoted` check or implements it incorrectly, an attacker can call the vote function repeatedly, accumulating vote weight with each call. Even a single token holder can inflate their influence arbitrarily.

This vulnerability is distinct from the vote-after-transfer attack, as the attacker does not need to move tokens between addresses. A simple repeated call from the same address is sufficient to exploit the flaw.

## Exploit Scenario

Bob holds 100 governance tokens. He calls `castVote(proposalId, true)`. The contract records his 100 votes for the proposal. Bob calls `castVote(proposalId, true)` again. The contract does not check whether Bob already voted and records another 100 votes. Bob repeats this 1000 times, casting 100,000 votes with only 100 tokens.

## Example

```solidity
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

contract VulnerableGovernor {
    IERC20 public token;

    struct Proposal {
        uint256 forVotes;
        uint256 againstVotes;
    }

    mapping(uint256 => Proposal) public proposals;

    function castVote(uint256 proposalId, bool support) external {
        Proposal storage proposal = proposals[proposalId];

        // Vulnerable: no check for whether msg.sender has already voted
        uint256 weight = token.balanceOf(msg.sender);

        if (support) {
            proposal.forVotes += weight;
        } else {
            proposal.againstVotes += weight;
        }

        // Missing: hasVoted[proposalId][msg.sender] = true;
    }
}
```

## Mitigations

- Implement a `hasVoted` mapping: `mapping(uint256 => mapping(address => bool)) hasVoted`.
- Check and set the flag before recording votes: `require(!hasVoted[proposalId][msg.sender])`.
- Emit events for off-chain monitoring of vote submissions.
- Use OpenZeppelin's `Governor` which handles duplicate vote prevention correctly.
