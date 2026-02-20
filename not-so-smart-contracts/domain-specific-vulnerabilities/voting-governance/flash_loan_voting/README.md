# Flash Loan Voting

Using current token balance for voting power allows flash loan-funded governance attacks.

## Description

Governance contracts that determine voting power from a token's current `balanceOf()` rather than a historical snapshot are vulnerable to flash loan attacks. An attacker can borrow a large number of governance tokens via a flash loan, vote on a proposal, and repay the loan within the same transaction. The attacker never owned the tokens but exerts significant governance influence.

This attack is economically rational because flash loans have minimal cost (a small fee) compared to the governance power gained. Any protocol that reads live token balances for vote weight is exposed, regardless of how robust other aspects of the governance system are.

## Exploit Scenario

Bob flash loans 10 million governance tokens from Aave. In the same transaction, he calls `castVote(proposalId, true)` on the governance contract, which reads `balanceOf(bob)` as 10 million. Bob then repays the flash loan. His vote counts as 10 million tokens despite never having held any governance tokens, swinging the proposal outcome.

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

    function castVote(uint256 proposalId, bool support) external {
        Proposal storage proposal = proposals[proposalId];
        require(!proposal.hasVoted[msg.sender], "Already voted");

        // Vulnerable: reads current balance, not a historical snapshot
        uint256 weight = token.balanceOf(msg.sender);

        if (support) {
            proposal.forVotes += weight;
        } else {
            proposal.againstVotes += weight;
        }

        proposal.hasVoted[msg.sender] = true;
    }
}
```

## Mitigations

- Use checkpoint-based voting power: `getPastVotes(account, proposalSnapshot)` where `proposalSnapshot` is a past block number.
- Store the snapshot block at proposal creation time, before voting begins.
- Never use current `balanceOf()` for governance decisions.
- Use OpenZeppelin's `ERC20Votes` extension, which provides built-in checkpoint and delegation support.
