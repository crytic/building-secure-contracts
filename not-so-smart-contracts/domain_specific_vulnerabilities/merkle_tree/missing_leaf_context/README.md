# Missing Leaf Context

Leaves without chain ID or contract address enable cross-chain and cross-contract replay.

## Description

Merkle proofs are cryptographic commitments to specific data. If the leaf hash does not include contextual bindings such as the chain ID, contract address, or distribution period, the same proof can be replayed across different environments. A proof valid on Ethereum mainnet can be replayed on Arbitrum if both deployments share the same Merkle root and the leaf lacks chain-specific data.

This vulnerability becomes increasingly common as protocols deploy across multiple EVM-compatible chains. When the same airdrop or whitelist contract is deployed with identical roots on several chains, every valid proof works on every chain. Similarly, if a protocol runs recurring distributions (epochs, seasons) and reuses the same leaf format without a period identifier, proofs from one period may be valid in another.

The fix mirrors the rationale behind EIP-712 domain separators: bind cryptographic commitments to their intended execution context.

## Exploit Scenario

A protocol deploys the same airdrop contract on Ethereum and Arbitrum with the same Merkle root. Alice claims her airdrop on Ethereum using a proof for `keccak256(abi.encode(alice, 1000))`. She then submits the identical proof and leaf on Arbitrum. Because the leaf contains no chain ID or contract address, the proof is valid on both chains, and Alice receives double the intended token allocation.

## Example

```solidity
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract VulnerableAirdrop {
    bytes32 public merkleRoot;
    IERC20 public token;
    mapping(address => bool) public claimed;

    function claim(uint256 amount, bytes32[] calldata proof) external {
        require(!claimed[msg.sender], "Already claimed");

        // Leaf contains no chain ID or contract address
        bytes32 leaf = keccak256(abi.encode(msg.sender, amount));

        require(MerkleProof.verify(proof, merkleRoot, leaf), "Invalid proof");

        claimed[msg.sender] = true;
        token.transfer(msg.sender, amount);
    }
}
```

## Mitigations

- Include `block.chainid` in the leaf hash to bind proofs to a specific chain.
- Include `address(this)` in the leaf hash to bind proofs to a specific contract deployment.
- Include a distribution period or epoch identifier for recurring distributions.
- Use EIP-712 structured data hashing for comprehensive domain separation.
