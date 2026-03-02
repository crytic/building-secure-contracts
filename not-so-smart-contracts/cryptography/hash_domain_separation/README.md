# Hash Domain Separation Failure

Missing length or type prefixes in hash inputs cause collisions across semantically different messages.

## Description

Hash functions should produce different outputs for semantically different inputs, even
when the raw byte representations happen to be identical. This property is called domain
separation. Without it, an attacker can craft two distinct inputs that hash to the same
value and exploit the collision to forge proofs, bypass authentication, or claim assets
belonging to someone else.

The problem is especially common in sponge-based, ZK-friendly hash functions that pad
inputs with zeros to a fixed width. If the original input length is not recorded, then
`hash([1])` and `hash([1, 0])` produce identical digests. The same class of bug appears
in Merkle trees when leaf nodes and branch nodes share a hashing scheme: an attacker can
submit a payload that is valid as both a leaf and a branch, breaking the tree's integrity.

## Exploit Scenario

Alice deploys a Merkle-tree-based asset registry that uses a sponge hash with zero-padding and no domain tags. Leaf nodes represent user balances and branch nodes represent internal tree structure. Bob constructs a crafted payload whose raw bytes match the concatenation of two existing leaf hashes. Because the tree uses the same hash function for leaves and branches without any prefix, Bob submits this payload as a leaf, and it produces a hash identical to an existing branch node. Bob uses the forged Merkle proof to claim assets belonging to other users, passing verification because the root hash remains valid.

## Example

A hash utility pads every input to a fixed width with trailing zeros but never encodes
the original length:

```pseudocode
function padded_hash(input[], width):
    padded = new Array(width, fill=0)
    copy input into padded[0..len(input)]
    return sponge_compress(padded)

// Two semantically different inputs collide:
h1 = padded_hash([0x61, 0x62, 0x00], width=8)
h2 = padded_hash([0x61, 0x62],       width=8)
assert h1 == h2   // collision -- both pad to [0x61, 0x62, 0, 0, 0, 0, 0, 0]

// Merkle tree without domain tags:
function merkle_node(left, right):
    return padded_hash(left || right, width=64)
function merkle_leaf(data):
    return padded_hash(data, width=64)
// A forged "leaf" whose bytes equal a valid branch concatenation
// produces the same root hash and passes verification.
```

An attacker who controls either input can substitute one for the other, forging
a valid hash for a message they never authored.

## Mitigations

- **Include the input length** as an explicit field in every hash invocation
  (e.g., prepend or append a fixed-size length encoding before hashing).
- **Use distinct domain tags** for structurally different inputs: prefix leaf
  hashes with `0x00` and branch hashes with `0x01`, or use separate tags for
  messages, keys, and nonces.
- **Follow the hash specification's padding rule exactly** -- many sponge
  constructions define a multi-rate padding (e.g., `pad10*1`) that already
  prevents these collisions when implemented correctly.
- **Never assume zero-padding is safe** without an accompanying length or
  domain marker; treat any padding scheme that discards length information
  as broken by default.
