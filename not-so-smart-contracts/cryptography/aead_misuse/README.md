# AEAD Metadata Authentication Failure

Authenticated Encryption with Associated Data (AEAD) schemes like AES-GCM authenticate both the ciphertext and any associated data (AAD) passed alongside it. However, the AAD must be explicitly provided by the caller -- any metadata not included in the AAD parameter is left completely unprotected. The authentication tag only covers what it is told to cover.

In encrypted communication protocols, frames typically contain unencrypted metadata (offsets, sizes, flags, sequence numbers) alongside the encrypted payload. If these header fields are not included in the AAD, an attacker can silently modify them without invalidating the authentication tag. This enables packet manipulation: reordering encrypted chunks, changing frame boundaries, altering routing metadata, or truncating messages -- all without detection by the receiver.

## Example

An encrypt function processes a frame containing a plaintext payload and an unencrypted header. The header holds offset and size fields that the receiver uses to reassemble data. Because the AAD is set to empty, the header is unauthenticated.

```pseudocode
struct Frame {
    header: { offset: int, size: int, flags: byte }
    payload: bytes
}

function encrypt_frame(frame, key, nonce):
    // BUG: AAD is empty -- header fields are not authenticated
    aad = empty
    ciphertext, tag = AES_GCM_Encrypt(key, nonce, frame.payload, aad)
    return frame.header || ciphertext || tag

function decrypt_frame(packet, key, nonce):
    header, ciphertext, tag = parse(packet)
    // Decryption succeeds even if an attacker modified header.offset or header.size
    plaintext = AES_GCM_Decrypt(key, nonce, ciphertext, aad = empty)
    return reassemble(plaintext, header.offset, header.size)

// Attack scenario:
// 1. Attacker intercepts the encrypted packet on the wire
// 2. Modifies header.offset from 0 to 1024
// 3. Forwards the packet to the receiver
// 4. AES-GCM tag verification PASSES (tag never covered the header)
// 5. Receiver reassembles plaintext at wrong position
```

## Mitigations

- Always pass all unencrypted metadata (headers, offsets, sizes, flags) as the AAD parameter to the AEAD encryption function so the tag covers them
- Authenticate frame structure fields -- sequence numbers, lengths, and boundary markers -- alongside the payload to prevent reordering and truncation attacks
- Verify during code review that no mutable or attacker-visible fields are excluded from the AAD; treat an empty AAD as a red flag when headers are present
- Use protocol-level integration tests that tamper with header fields and confirm that decryption rejects the modified frame
