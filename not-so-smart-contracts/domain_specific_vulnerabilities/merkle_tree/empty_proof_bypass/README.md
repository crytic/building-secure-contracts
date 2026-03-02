# Empty Proof Bypass

Verification accepts empty proof arrays, allowing any leaf to be validated as the root.

## Description

Merkle proof verification typically iterates over each element in the proof array, hashing the computed hash with the next proof element at each step. When the proof array is empty, the loop body never executes, and the initial value (the leaf) is returned as the computed root. The final comparison then reduces to `leaf == root`.

An attacker who knows the Merkle root stored in the contract can exploit this by submitting the root value as the leaf with an empty proof array. The verification loop is skipped entirely, and the equality check passes. This bypasses the entire Merkle tree verification mechanism.

This vulnerability affects any system that gates access via Merkle proofs, including airdrops, token whitelists, and allowlist-based minting. The Merkle root is typically public (stored on-chain or emitted in events), making this attack trivial to execute.

## Exploit Scenario

A token airdrop contract verifies claims using a Merkle proof. Bob observes the Merkle root stored in the contract by reading the public `merkleRoot` state variable. He calls `claim()` with the root value as the leaf and an empty proof array. The verification loop is skipped, `leaf == root` evaluates to true, and Bob receives airdrop tokens without being in the original distribution list.

## Example

```solidity
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract VulnerableAirdrop {
    bytes32 public merkleRoot;
    IERC20 public token;

    constructor(bytes32 _root, IERC20 _token) {
        merkleRoot = _root;
        token = _token;
    }

    function claim(uint256 amount, bytes32[] calldata proof) external {
        bytes32 leaf = keccak256(abi.encode(msg.sender, amount));
        require(verify(proof, merkleRoot, leaf), "Invalid proof");
        token.transfer(msg.sender, amount);
    }

    function verify(
        bytes32[] calldata proof,
        bytes32 root,
        bytes32 leaf
    ) internal pure returns (bool) {
        bytes32 computedHash = leaf;
        // If proof is empty, this loop never executes
        for (uint256 i = 0; i < proof.length; i++) {
            computedHash = keccak256(abi.encodePacked(computedHash, proof[i]));
        }
        return computedHash == root; // Returns leaf == root when proof is empty
    }
}
```

## Mitigations

- Require that the proof length equals the expected tree depth: `require(proof.length == TREE_DEPTH)`.
- Reject empty proof arrays explicitly with `require(proof.length > 0)`.
- Use OpenZeppelin's `MerkleProof` library, which handles edge cases correctly.
- Double-hash leaves so that the leaf value cannot equal the root.
