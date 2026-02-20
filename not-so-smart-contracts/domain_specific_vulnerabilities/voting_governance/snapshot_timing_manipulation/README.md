# Snapshot Timing Manipulation

Creating proposals with same-block or predictable snapshots enables vote power front-running.

## Description

Governance proposals use a snapshot block to determine each voter's voting power. If the snapshot is set to the current block at proposal creation time, an attacker can acquire tokens (via purchase or flash loan), create the proposal, and vote in the same block. The snapshot captures the attacker's inflated balance because the token acquisition and proposal creation occur in the same block.

Even without flash loans, if the snapshot block is predictable, an attacker can acquire tokens just before the snapshot is taken. The attacker gains governance influence without sustained token exposure, undermining the assumption that voting power reflects long-term stakeholder alignment.

## Exploit Scenario

Bob purchases 5 million governance tokens on a DEX. In the same transaction, he calls `propose()` on the governance contract, which sets the snapshot to `block.number`. Bob then calls `castVote()`. The snapshot captures Bob's 5 million tokens. After the proposal passes or fails, Bob sells the tokens. He influenced governance without long-term token exposure.

## Example

```solidity
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/extensions/ERC20Votes.sol";

contract VulnerableGovernor {
    ERC20Votes public token;
    uint256 public proposalCount;

    struct Proposal {
        uint256 snapshotBlock;
        uint256 forVotes;
        uint256 againstVotes;
        uint256 endBlock;
    }

    mapping(uint256 => Proposal) public proposals;

    function propose() external returns (uint256) {
        proposalCount++;

        // Vulnerable: snapshot is current block, same-block voting possible
        proposals[proposalCount] = Proposal({
            snapshotBlock: block.number,
            forVotes: 0,
            againstVotes: 0,
            endBlock: block.number + 50400
        });

        return proposalCount;
    }
}
```

## Mitigations

- Set the snapshot to a past block: `proposalSnapshot = block.number - 1`.
- Add a voting delay period between proposal creation and voting start.
- Require a minimum proposal threshold to prevent spam proposals.
- Use OpenZeppelin's `Governor` which implements a configurable voting delay.
