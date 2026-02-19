# Missing Claim Replay Protection

Absence of claim tracking allows the same proof to be used multiple times.

## Description

Merkle-based distribution systems such as airdrops and reward contracts must track which claims have been processed. If the contract does not record completed claims, a user can submit the same valid proof repeatedly to receive multiple payouts. The contract will verify the proof successfully each time, transferring tokens on every call.

Even when a `claimed` mapping exists, the tracking mechanism must use a unique identifier for each leaf. Tracking by leaf hash alone creates issues if the tree contains duplicate leaf values. Tracking by `msg.sender` is insufficient if the tree contains multiple entries for the same address. The recommended pattern is to assign a unique index to each leaf and track claims using a bitmap, which is both gas-efficient and unambiguous.

## Exploit Scenario

Alice has a valid Merkle proof for 1000 tokens in an airdrop. She calls `claim()` and receives 1000 tokens. The contract does not set a `claimed` flag. Alice calls `claim()` again with the same proof and receives another 1000 tokens. She repeats this until the airdrop contract is drained of its entire token balance.

## Example

```solidity
contract VulnerableAirdrop {
    bytes32 public merkleRoot;
    IERC20 public token;

    // No claimed tracking at all
    function claim(
        address account,
        uint256 amount,
        bytes32[] calldata proof
    ) external {
        bytes32 leaf = keccak256(abi.encode(account, amount));
        require(MerkleProof.verify(proof, merkleRoot, leaf), "Invalid proof");

        // Transfers tokens every time this function is called
        token.transfer(account, amount);
    }
}
```

## Mitigations

- Track claims by unique leaf index using a bitmap: `mapping(uint256 => uint256) claimedBitmap`.
- Include a unique index in each leaf: `keccak256(abi.encode(index, account, amount))`.
- Verify the index is within bounds before marking as claimed.
- Use OpenZeppelin's `MerkleDistributor` pattern, which implements bitmap-based claim tracking.
