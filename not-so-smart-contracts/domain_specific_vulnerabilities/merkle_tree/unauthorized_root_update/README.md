# Unauthorized Root Update

Missing access control on root update functions allows arbitrary Merkle root replacement.

## Description

The Merkle root is the trust anchor for all proof-based operations in a contract. If the function that sets the Merkle root lacks access control, any user can replace the root with one computed from a custom tree containing their own crafted entries. This grants the attacker the ability to construct valid proofs for arbitrary claims, effectively giving them full control over the distribution or whitelist.

This vulnerability is a specific instance of the broader missing access control pattern, but it is especially severe in the Merkle tree context. Unlike other state variables where unauthorized modification might cause limited damage, replacing the Merkle root invalidates all existing legitimate proofs and enables the attacker to authorize any action the Merkle tree was designed to gate.

The attack is straightforward: construct a tree, compute the root, update the contract, and submit a valid proof against the new root.

## Exploit Scenario

An airdrop contract has a `setMerkleRoot(bytes32)` function with no access modifier. Bob constructs a Merkle tree with a single leaf granting himself the contract's entire token balance. He calls `setMerkleRoot()` with his custom root, then calls `claim()` with a valid proof against his root. The verification succeeds, and Bob drains the entire token balance from the contract.

## Example

```solidity
contract VulnerableAirdrop {
    bytes32 public merkleRoot;
    IERC20 public token;
    mapping(address => bool) public claimed;

    // No access control — anyone can call this
    function setMerkleRoot(bytes32 _root) external {
        merkleRoot = _root;
    }

    function claim(uint256 amount, bytes32[] calldata proof) external {
        require(!claimed[msg.sender], "Already claimed");

        bytes32 leaf = keccak256(abi.encode(msg.sender, amount));
        require(MerkleProof.verify(proof, merkleRoot, leaf), "Invalid proof");

        claimed[msg.sender] = true;
        token.transfer(msg.sender, amount);
    }
}
```

## Mitigations

- Add `onlyOwner` or role-based access control to root update functions.
- Emit events on root changes for off-chain monitoring and alerting.
- Consider using a timelock for root updates to allow detection before activation.
- Use multi-sig governance for root management in high-value contracts.
