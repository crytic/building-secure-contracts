# Missing Secret Data Zeroization

Temporary secrets left in memory after use are recoverable from dumps, enabling private key reconstruction.

## Description

Cryptographic protocols frequently generate temporary secrets -- presignatures, key shares, intermediate
scalars, and ephemeral private keys -- that must be erased from memory immediately after use. If these
buffers are not explicitly zeroized, their contents persist in RAM even after the memory is freed or the
stack frame returns. An attacker with access to memory dumps, core files, or cold boot images can recover
these values and reconstruct private keys.

The problem is compounded by compiler optimizations. When a buffer is zeroed but never read again, the
compiler may remove the store entirely as a dead store elimination. This means a straightforward `memset`
before `return` can be silently deleted, leaving secrets intact. In threshold signing schemes this is
especially dangerous: presignatures and multiplicative triples are one-time-use, so recovering even a
single old value from memory can allow full reconstruction of the long-term secret.

## Exploit Scenario

Alice deploys a threshold signing service that generates ephemeral keys for each signature operation. The signing function stores the ephemeral key in a stack buffer, computes the signature, and calls `memset` to clear the buffer before returning. The compiler, running with `-O2` optimization, detects that `tmp_secret` is never read after the `memset` and eliminates the zeroization as a dead store. Bob, who gains read access to the server's memory through a separate vulnerability, captures a core dump and recovers the ephemeral key from the uncleared stack frame. Using the recovered ephemeral key and the corresponding signature, Bob computes the long-term private key and drains the signing wallet.

## Example

The signing function below creates a temporary secret key on the stack, uses it, and attempts to clear
it before returning. The compiler is free to remove the `memset` because `tmp_secret` is not read
afterward.

```c
int sign_message(const uint8_t *msg, size_t msg_len, uint8_t *sig_out) {
    uint8_t tmp_secret[32];

    derive_ephemeral_key(tmp_secret);
    compute_signature(tmp_secret, msg, msg_len, sig_out);

    memset(tmp_secret, 0, sizeof(tmp_secret));  // may be optimized away
    return 0;
}
```

## Mitigations

- Use platform-specific secure zeroization functions that the compiler cannot remove: `explicit_bzero` (POSIX), `SecureZeroMemory` (Windows), or the `zeroize` crate (Rust)
- If no platform primitive is available, write through a `volatile` function pointer or insert a compiler barrier after the zeroization to prevent dead store elimination
- Zeroize all temporary secret material -- ephemeral keys, presignatures, nonces, key shares, and intermediate scalars -- as soon as they are no longer needed
- Audit heap-allocated secrets as well; `free()` does not clear memory, so zeroize buffers before deallocation
- Prefer memory allocators or secret-storage types that automatically zeroize on drop or deallocation
- Include zeroization checks in code review checklists and test with compiler optimizations enabled (`-O2`, `--release`) to verify the scrub is not eliminated
