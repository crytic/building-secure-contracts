# Nonce and Randomness Reuse

Reusing a nonce in cryptographic protocols has catastrophic consequences. In ECDSA signing, if the same nonce `k` is used for two different messages under the same private key, an attacker can recover the private key through simple algebra: subtracting the two signature equations cancels `k` and isolates the secret scalar. This is not a theoretical concern -- it has led to real-world key extractions.

The damage extends beyond signatures. In AEAD schemes like ChaCha20-Poly1305 or AES-GCM, reusing a `(key, nonce)` pair breaks both confidentiality and authenticity. An attacker can XOR two ciphertexts to eliminate the keystream and recover plaintext, and can forge authentication tags. In MPC or DKG communication channels, if two parties encrypt different messages with the same shared key and nonce, XORing the ciphertexts cancels the stream cipher entirely, exposing both plaintexts.

## Example

A signing function derives the nonce from a counter, but the counter wraps after 2^32 operations, causing nonce reuse and enabling private key recovery.

```c
uint32_t nonce_counter = 0;

signature_t sign(private_key_t sk, message_t msg) {
    // BUG: counter wraps at 2^32, reusing previous nonces
    nonce_counter++;
    byte nonce_k[32] = hash(nonce_counter);

    // ECDSA: s = k^{-1} * (hash(msg) + sk * r) mod n
    point_t  R = nonce_k * G;
    scalar_t r = R.x mod n;
    scalar_t s = inv(nonce_k) * (hash(msg) + sk * r) mod n;
    return (r, s);
}

// After 2^32 + 1 signatures, nonce_k repeats.
// Given two signatures (r, s1) and (r, s2) over messages m1, m2
// that share the same k (and therefore the same r):
//
//   s1 - s2 = k^{-1} * (hash(m1) - hash(m2))  mod n
//   k       = (hash(m1) - hash(m2)) / (s1 - s2) mod n
//   sk      = (s1 * k - hash(m1)) / r            mod n
//
// The private key sk is now fully recovered.
```

The same class of bug applies to AEAD channels. If an MPC node encrypts two
different round messages under the same `(shared_key, nonce)` pair, an
observer can XOR the two ciphertexts to cancel the keystream and obtain the
XOR of the two plaintexts, from which both can often be recovered.

## Mitigations

- Use **RFC 6979** deterministic nonce generation for ECDSA, which derives `k` from the private key and message hash, making reuse impossible without identical inputs
- Never reuse a `(key, nonce)` pair in AEAD encryption; use a monotonic counter or random nonce large enough (e.g., 192-bit XChaCha20) to make collisions negligible
- In MPC/DKG channels, bind nonces to the unique session ID, round number, and sender identity so that each encrypted message uses a distinct nonce by construction
- Prefer cryptographic primitives with built-in misuse resistance (e.g., SIV or nonce-misuse-resistant AEAD) where performance allows
- Audit any custom nonce derivation logic for overflow, truncation, or reset conditions that could silently reintroduce a previously used value
