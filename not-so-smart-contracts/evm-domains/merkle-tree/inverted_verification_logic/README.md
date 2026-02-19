# Inverted Verification Logic

Negated boolean in proof verification accepts invalid proofs and rejects valid ones.

## Description

A single misplaced negation operator in the Merkle proof verification check inverts the security guarantee entirely. Instead of requiring a valid proof to proceed, the contract requires an invalid proof. All legitimate users with valid proofs are rejected, while anyone submitting an invalid or random proof passes verification.

This bug is subtle because it produces the exact opposite of expected behavior. During testing, if only positive test cases are written (checking that valid proofs succeed), the negated check will cause those tests to fail, prompting investigation. However, if the test suite is incomplete, only tests happy paths with mocked verification, or the developer "fixes" the test to match the buggy behavior, the contract may deploy with fully inverted access control.

The vulnerability is particularly dangerous in production because every address that is not in the Merkle tree gains access, while every legitimate participant is locked out.

## Exploit Scenario

Bob submits a random proof and leaf to the claim contract. The verification computes a root that does not match the stored Merkle root, so `MerkleProof.verify()` returns `false`. The contract checks `require(!MerkleProof.verify(...))`, which evaluates to `require(!false)`, which is `require(true)`. Bob's invalid proof passes, and he claims tokens he was never allocated.

## Example

```solidity
contract VulnerableAirdrop {
    bytes32 public merkleRoot;
    IERC20 public token;
    mapping(address => bool) public claimed;

    function claim(uint256 amount, bytes32[] calldata proof) external {
        require(!claimed[msg.sender], "Already claimed");

        bytes32 leaf = keccak256(abi.encode(msg.sender, amount));

        // Bug: negation inverts the security check
        require(!MerkleProof.verify(proof, merkleRoot, leaf), "Invalid proof");

        claimed[msg.sender] = true;
        token.transfer(msg.sender, amount);
    }
}
```

## Mitigations

- Use positive assertions for security checks: `require(MerkleProof.verify(proof, root, leaf))`.
- Add integration tests that verify both valid proofs and invalid proofs behave correctly.
- Use static analysis tools to flag negated security-critical boolean expressions.
- Conduct peer review specifically focused on access control logic.
