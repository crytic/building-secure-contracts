# Timing Side-Channel Leaks

Cryptographic implementations that use secret-dependent branches, early returns, or variable-time
arithmetic leak information about secret keys through execution timing. An attacker who can measure
how long an operation takes can infer secret bits -- for example, the Hamming weight of a scalar
used in elliptic curve multiplication, or individual key bytes in a comparison function.

This class of vulnerability affects scalar multiplication, rejection sampling loops, modular
inversion, and any code path where control flow or memory access patterns depend on secret data.

## Example

The following field negation function returns early when the input is zero. Because the zero case
skips the subtraction, execution time reveals whether the secret scalar contains zero limbs.

```c
// VULNERABLE: non-constant-time conditional negation
void field_negate(uint32_t *r, const uint32_t *a, int flag) {
    if (flag == 0) {
        // Early return leaks the value of 'flag' through timing
        copy(r, a);
        return;
    }
    // Full subtraction only runs when flag != 0
    for (int i = 0; i < NUM_LIMBS; i++) {
        r[i] = FIELD_PRIME[i] - a[i];
    }
    propagate_borrow(r);
}

// FIXED: constant-time conditional negation
void field_negate_ct(uint32_t *r, const uint32_t *a, int flag) {
    uint32_t mask = -(uint32_t)(flag != 0);  // 0x00000000 or 0xFFFFFFFF
    uint32_t neg[NUM_LIMBS];
    for (int i = 0; i < NUM_LIMBS; i++) {
        neg[i] = FIELD_PRIME[i] - a[i];
    }
    propagate_borrow(neg);
    for (int i = 0; i < NUM_LIMBS; i++) {
        r[i] = (a[i] & ~mask) | (neg[i] & mask);  // constant-time select
    }
}
```

## Mitigations

- Use well-tested constant-time libraries for all field and scalar arithmetic
- Replace secret-dependent branches with branchless selects using bitwise masks
- Use constant-time comparison functions (e.g., `subtle.ConstantTimeCompare`, `CRYPTO_memcmp`)
- Avoid early returns or short-circuit evaluation on secret-dependent conditions
- Validate implementations with timing analysis tools (e.g., dudect, ctgrind, timecop)
- Ensure compiler optimizations do not reintroduce branches into branchless code
