# Arbitrary Proof Length

Accepting proofs of any length enables collision attacks or denial of service.

## Description

A correctly constructed Merkle tree of depth `d` always produces proofs of exactly `d` elements. If the verification function does not enforce this constraint, two categories of attacks become possible.

First, a shortened proof allows second preimage attacks where intermediate nodes are presented as leaves. An attacker submits fewer proof elements than expected, causing verification to terminate at an internal node rather than the root. If the intermediate node happens to equal the root (or if combined with a leaf-node collision), verification succeeds with a forged leaf.

Second, an excessively long proof forces unnecessary hash computations. An attacker submits a proof with thousands of elements, causing the verifier to compute thousands of hash operations per call. This enables gas-based denial of service, particularly in contracts that process claims in loops or batches.

Both attacks exploit the absence of a `require(proof.length == TREE_DEPTH)` check.

## Exploit Scenario

A whitelist tree has depth 20. Bob submits a proof with only 10 elements, using an intermediate node at depth 10 as the leaf. Because the contract does not validate proof length, verification succeeds with the intermediate node hash matching the root after only 10 hashing steps. In a separate attack, Bob submits a proof with 1000 elements to a batch-processing function, forcing the verifier to compute 1000 hash operations per claim, consuming excessive gas and blocking legitimate transactions.

## Example

```solidity
contract VulnerableWhitelist {
    bytes32 public merkleRoot;
    // Tree depth is 20, but never enforced

    function isWhitelisted(
        address account,
        bytes32[] calldata proof
    ) public view returns (bool) {
        bytes32 leaf = keccak256(abi.encode(account));
        bytes32 computedHash = leaf;

        // No check on proof.length — accepts any length
        for (uint256 i = 0; i < proof.length; i++) {
            if (computedHash <= proof[i]) {
                computedHash = keccak256(abi.encodePacked(computedHash, proof[i]));
            } else {
                computedHash = keccak256(abi.encodePacked(proof[i], computedHash));
            }
        }

        return computedHash == merkleRoot;
    }
}
```

## Mitigations

- Store the expected tree depth as an immutable constant: `uint256 public immutable TREE_DEPTH`.
- Require `proof.length == TREE_DEPTH` before executing the verification loop.
- Reject proofs that are shorter or longer than the expected depth.
