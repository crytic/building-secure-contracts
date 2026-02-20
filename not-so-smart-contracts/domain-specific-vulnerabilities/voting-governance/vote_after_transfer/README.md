# Vote After Transfer

Transferring tokens after voting allows the same tokens to vote multiple times.

## Description

If voting power is determined by current balance rather than a historical snapshot, an attacker can vote with their tokens, transfer them to another address, and vote again from the new address. The same tokens are counted twice. This extends to chains of transfers, where tokens pass through many addresses, each voting before forwarding.

The attack requires no flash loans, just multiple addresses controlled by the attacker, making it cheap and difficult to detect. Each additional address multiplies the effective voting power, and the attacker retains full custody of the tokens throughout the process.

## Exploit Scenario

Bob holds 10,000 governance tokens. He votes "for" on a proposal from address A. He then transfers all 10,000 tokens to address B and votes "for" again. He repeats the transfer to addresses C, D, and E, voting each time. The proposal records 50,000 "for" votes from only 10,000 tokens.

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
        mapping(address => bool) hasVoted;
    }

    mapping(uint256 => Proposal) public proposals;

    // Vulnerable: reads current balance, not snapshot balance
    function castVote(uint256 proposalId, bool support) external {
        Proposal storage proposal = proposals[proposalId];
        require(!proposal.hasVoted[msg.sender], "Already voted");

        uint256 weight = token.balanceOf(msg.sender);

        if (support) {
            proposal.forVotes += weight;
        } else {
            proposal.againstVotes += weight;
        }

        proposal.hasVoted[msg.sender] = true;
        // Tokens can be transferred after voting, then used to vote from another address
    }
}
```

## Mitigations

- Use snapshot-based voting power at the proposal's snapshot block.
- Implement checkpoints that record historical balances at each block.
- Reject votes from accounts whose balance at the snapshot block was zero.
- Use OpenZeppelin's `ERC20Votes` for built-in checkpoint tracking.
