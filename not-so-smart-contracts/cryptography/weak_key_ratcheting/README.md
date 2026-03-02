# Weak Key Ratcheting

Static or epoch-bound keys lack forward secrecy, allowing one key compromise to expose all messages.

## Description

A key ratchet is supposed to evolve the encryption key after every operation so that compromising the current key does not reveal past plaintext (forward secrecy) or future plaintext (post-compromise security). Two common failures break this guarantee.

**Static key ratchet.** The ratchet derives the encryption key from a fixed value -- such as a user ID or a long-lived seed -- with no ephemeral component. Because the inputs never change, the "ratchet" produces the same key every time. Compromising it once exposes every past and future message. **Weak intra-epoch forward secrecy.** In group protocols that use epoch-based key management, a single symmetric key protects all messages within an epoch. If an attacker obtains the sender's key mid-epoch, they can decrypt every message in that epoch. Without per-message ratcheting inside epochs, one compromised message key exposes the entire epoch.

## Exploit Scenario

Alice deploys a group messaging protocol that uses epoch-based key management. Within each epoch, a single symmetric `epoch_key` encrypts all messages, with only the nonce changing per message. Bob compromises Alice's device mid-epoch and extracts the current `epoch_key`. Because no per-message ratcheting occurs within the epoch, Bob decrypts every message sent during that epoch -- both before and after the compromise. Furthermore, the key derivation function uses only the static group secret and a user ID with no ephemeral input, so the same key is produced every epoch. Bob now has access to the complete message history.

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

## Mitigations

- Incorporate an ephemeral Diffie-Hellman exchange into the key ratchet so that each session (or message) introduces fresh randomness an attacker cannot predict.
- Ratchet the symmetric chain key after every message, not just at epoch boundaries. Delete old keys immediately to preserve forward secrecy within an epoch.
- Adopt the Double Ratchet pattern or an equivalent scheme that combines a DH ratchet with a symmetric ratchet, providing both forward secrecy and post-compromise security.
- Audit that the ratchet state actually changes: write tests asserting consecutive calls never produce the same key.
