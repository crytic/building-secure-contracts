# Leaf-Node Hash Collision

Identical pre-hash sizes for leaves and internal nodes enable second preimage attacks.

## Description

In a standard Merkle tree, internal nodes are computed as `hash(left || right)`, producing a 64-byte pre-image from two concatenated 32-byte hashes. If leaf data is also encoded as exactly 64 bytes before hashing, the domain between leaves and internal nodes becomes ambiguous. For example, `abi.encodePacked(uint256, uint256)` produces a 64-byte pre-image identical in structure to a node concatenation.

An attacker can exploit this ambiguity by presenting an intermediate node as a leaf value with a shortened proof. This is a second preimage attack: the attacker identifies an internal node whose children are `(X, Y)`, then submits `X` as one leaf field and `Y` as another. The resulting hash matches the internal node, and verification succeeds against a truncated proof path.

This class of vulnerability is well-documented in cryptographic literature and is the reason standards such as RFC 6962 mandate domain separation between leaf and node hashing.

## Exploit Scenario

An airdrop tree hashes leaves as `keccak256(abi.encodePacked(uint256(address), uint256(amount)))`, producing a 64-byte pre-image. Bob observes the published tree structure and identifies an internal node whose left child hash is `X` and right child hash is `Y`. He submits `X` as the address parameter and `Y` as the amount parameter along with a shortened proof that starts one level higher. The verification succeeds because `keccak256(abi.encodePacked(X, Y))` equals the internal node hash, and Bob claims tokens using a fabricated identity.

## Example

```solidity
contract VulnerableAirdrop {
    bytes32 public merkleRoot;
    IERC20 public token;

    function claim(
        uint256 account,
        uint256 amount,
        bytes32[] calldata proof
    ) external {
        // 64-byte pre-image matches internal node concatenation size
        bytes32 leaf = keccak256(abi.encodePacked(account, amount));
        require(MerkleProof.verify(proof, merkleRoot, leaf), "Invalid proof");
        token.transfer(address(uint160(account)), amount);
    }
}
```

## Mitigations

- Double-hash leaf data: `keccak256(abi.encode(keccak256(abi.encode(account, amount))))`.
- Use `abi.encode` instead of `abi.encodePacked` to produce padded, unambiguous encodings.
- Add a domain separator prefix byte (0x00 for leaves, 0x01 for internal nodes) before hashing.
- Use OpenZeppelin's `MerkleProof` library with the recommended double-hashing pattern.
