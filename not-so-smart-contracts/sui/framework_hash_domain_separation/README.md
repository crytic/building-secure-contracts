# Framework Hash Domain Separation

Sui's framework computes hashes internally for critical operations such as identifying dynamic fields and verifying package digests. When these hash computations concatenate variable-length inputs without length prefixes or domain separators, an attacker can craft two semantically different inputs that produce the same hash. The resulting collision lets the attacker confuse the framework into treating distinct objects or packages as identical.

Two instances of this pattern have been found in Sui's framework. First, `hash_type_and_key` in `dynamic_field.rs` computes `SHA3-256(parent || k_bytes || k_tag_bytes)` without length delimiters. Because `Struct` and `Vector` data types have semi-arbitrary byte representations, it is possible to shift bytes between `k_bytes` and `k_tag_bytes` to produce the same hash for different keys, causing `add` and `exists_` to misidentify fields. Second, `compute_digest_for_modules_and_deps` in `move_package.rs` hashes sorted module bytes by concatenating them without separators. A package with modules `[m1, m2]` can produce the same digest as a package with a single module `[m1 || m2]`, allowing protocols that rely on the digest for upgrade validation to be tricked.

## Example

The vulnerable pattern concatenates variable-length components directly before hashing:

```rust
// Vulnerable: no length prefix between components.
fn hash_type_and_key(parent: ObjectID, k_bytes: &[u8], k_tag_bytes: &[u8]) -> ObjectID {
    let mut hasher = Sha3_256::default();
    hasher.update(parent.as_ref());
    hasher.update(k_bytes);       // attacker shifts tail bytes of k_bytes...
    hasher.update(k_tag_bytes);   // ...into the head of k_tag_bytes -> same hash
    let hash = hasher.finalize();
    ObjectID::new(hash.into())
}
```

An attacker can choose `k_bytes = [A, B, C]` with `k_tag_bytes = [D]` and `k_bytes = [A, B]` with `k_tag_bytes = [C, D]`. Both inputs yield the identical SHA3-256 digest because the concatenated byte stream is the same.

The fix inserts a little-endian length prefix before each variable-length component so that the boundary between fields is unambiguous:

```rust
// Fixed: length-prefix each variable-length component.
fn hash_type_and_key(parent: ObjectID, k_bytes: &[u8], k_tag_bytes: &[u8]) -> ObjectID {
    let mut hasher = Sha3_256::default();
    hasher.update(parent.as_ref());
    hasher.update(&(k_bytes.len() as u64).to_le_bytes());
    hasher.update(k_bytes);
    hasher.update(&(k_tag_bytes.len() as u64).to_le_bytes());
    hasher.update(k_tag_bytes);
    let hash = hasher.finalize();
    ObjectID::new(hash.into())
}
```

## Mitigations

- Always include a length prefix (e.g., `len.to_le_bytes()`) before each variable-length component when computing a hash over concatenated inputs.
- Hash each component independently and combine the resulting digests, so that boundaries between inputs are inherently enforced.
- Follow domain separation best practices: prepend a unique tag or context string to each hash computation to prevent cross-protocol collisions.
- Audit all framework-level hash functions for the concatenation-without-delimiter pattern, especially where inputs come from user-controlled data or have variable-length encodings.
- Add test cases that explicitly attempt to produce collisions by shifting bytes across component boundaries.
