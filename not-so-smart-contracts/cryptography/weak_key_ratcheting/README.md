# Weak Key Ratcheting

A key ratchet is supposed to evolve the encryption key after every operation so that compromising the current key does not reveal past plaintext (forward secrecy) or future plaintext (post-compromise security). Two common failures break this guarantee.

**Static key ratchet.** The ratchet derives the encryption key from a fixed value -- such as a user ID or a long-lived seed -- with no ephemeral component. Because the inputs never change, the "ratchet" produces the same key every time. Compromising it once exposes every past and future message. **Weak intra-epoch forward secrecy.** In group protocols that use epoch-based key management, a single symmetric key protects all messages within an epoch. If an attacker obtains the sender's key mid-epoch, they can decrypt every message in that epoch. Without per-message ratcheting inside epochs, one compromised message key exposes the entire epoch.

## Example

The pseudocode below shows a ratchet that never actually ratchets. The key is a deterministic function of two static values, so it is identical across every call.

```pseudocode
function derive_message_key(static_secret, user_id):
    // No ephemeral input -- key never changes
    return HKDF(input_key = static_secret,
                 salt    = user_id,
                 info    = "msg-key")

function send_message(plaintext, static_secret, user_id):
    key = derive_message_key(static_secret, user_id)   // same key every time
    nonce = random_bytes(12)
    return AEAD_Encrypt(key, nonce, plaintext)

// An attacker who learns static_secret once can decrypt
// every past and future message for that user.
```

Even when a ratchet does advance, epoch-based group protocols often share a single symmetric
key across all messages within an epoch. If an attacker compromises the sender's key mid-epoch,
every message in that epoch is exposed:

```pseudocode
function send_epoch_message(plaintext, epoch_key, msg_counter):
    // BUG: all messages in the epoch use the same epoch_key
    // Compromising epoch_key reveals every message from this epoch
    nonce = msg_counter
    return AEAD_Encrypt(epoch_key, nonce, plaintext)
```

A correct ratchet feeds the previous key (or fresh DH output) back into the derivation so the key evolves with every message.

```pseudocode
function ratchet_message_key(chain_key):
    message_key = HKDF(input_key = chain_key, info = "msg-key")
    next_chain  = HKDF(input_key = chain_key, info = "chain-advance")
    return message_key, next_chain

function send_message(plaintext, chain_key):
    key, chain_key = ratchet_message_key(chain_key)
    nonce = random_bytes(12)
    ciphertext = AEAD_Encrypt(key, nonce, plaintext)
    delete(key)                       // zeroize after use
    return ciphertext, chain_key      // caller stores updated chain_key
```

## Mitigations

- Incorporate an ephemeral Diffie-Hellman exchange into the key ratchet so that each session (or message) introduces fresh randomness an attacker cannot predict.
- Ratchet the symmetric chain key after every message, not just at epoch boundaries. Delete old keys immediately to preserve forward secrecy within an epoch.
- Adopt the Double Ratchet pattern or an equivalent scheme that combines a DH ratchet with a symmetric ratchet, providing both forward secrecy and post-compromise security.
- Audit that the ratchet state actually changes: write tests asserting consecutive calls never produce the same key.
