# Missing Root Validation

Proof verified against a user-supplied root instead of the stored root.

## Description

Merkle proof verification computes a root from the leaf and proof elements, then compares it against an expected root. The security of this mechanism depends entirely on the expected root being a trusted value stored in contract state. If the contract accepts the root as a user-provided parameter instead of reading it from storage, an attacker can supply any root value along with a matching proof.

This completely defeats the purpose of the Merkle tree. The attacker controls both the proof and the root it is verified against, allowing them to construct arbitrary trees that verify successfully. The contract has no way to distinguish between a legitimate proof against the real root and a fabricated proof against an attacker-chosen root.

This vulnerability often arises when developers extract the verification logic into a generic helper function that takes the root as a parameter, then forget to compare the result against the stored root in the calling function.

## Exploit Scenario

A token claim contract accepts `(proof, root, leaf)` as parameters and verifies that the proof produces the given root. Bob constructs his own Merkle tree containing a single leaf that grants him 1 million tokens. He submits his custom proof, his custom root, and his crafted leaf to the `claim()` function. Verification succeeds because the proof is valid for his custom root. Bob claims 1 million tokens from the contract.

## Example

```solidity
contract VulnerableAirdrop {
    IERC20 public token;
    // merkleRoot is stored but never used for comparison
    bytes32 public merkleRoot;

    function claim(
        uint256 amount,
        bytes32[] calldata proof,
        bytes32 root // Root supplied by caller — never validated
    ) external {
        bytes32 leaf = keccak256(abi.encode(msg.sender, amount));

        // Verifies against user-supplied root, not stored merkleRoot
        require(MerkleProof.verify(proof, root, leaf), "Invalid proof");

        token.transfer(msg.sender, amount);
    }
}
```

## Mitigations

- Always read the Merkle root from contract storage: `bytes32 root = merkleRoot`.
- Never accept the root as a function parameter in claim or verification functions.
- Use a setter function with appropriate access controls (`onlyOwner`) for root updates.
- Add assertions in tests that verify claims fail when using a different root.
