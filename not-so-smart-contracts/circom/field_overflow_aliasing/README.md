# Field Overflow Aliasing

Full-field-width bit decompositions allow aliased values to bypass range checks and comparisons.

## Description

Circom operates over a prime field (typically the BN128 scalar field, p ≈ 2^254). The standard `Num2Bits(n)` template decomposes a field element into `n` bits by constraining each bit to be 0 or 1, and checking that the weighted sum of bits equals the input. However, when `n` is 254 (the full field width), both `x` and `p + x` decompose into valid `n`-bit representations because `p + x mod p = x`. A malicious prover can substitute `p + x` for any value `x`, bypassing range checks, uniqueness assumptions, or comparison logic that depends on the bit decomposition being canonical.

This affects any circuit that uses `Num2Bits(254)` or similar full-field-width decompositions. The value `x` and `p + x` are identical in the field, so both pass the bit decomposition constraint — but they produce different bit patterns, which can fool downstream comparisons.

## Exploit Scenario

Alice deploys a ZK voting circuit that uses `Num2Bits(254)` to decompose voter weights and a `LessThan(254)` comparator to enforce a maximum weight of 100. Bob discovers that submitting `value = p + 50` passes all field arithmetic checks (since `p + 50 mod p = 50`) but produces a different bit pattern than 50. The `LessThan` comparator, operating on the aliased bit decomposition, incorrectly evaluates the comparison, allowing Bob to bypass the weight cap and cast votes with disproportionate influence.

## Example

A circuit that checks whether an input is less than a threshold by decomposing it into bits. With `n = 254`, the prover can submit `p + small_value` which wraps to `small_value` in the field but has a large bit representation:

```circom
template RangeCheck() {
    signal input value;
    signal input max_value;

    // BUG: n = 254 allows aliased inputs
    component bits = Num2Bits(254);
    bits.in <== value;

    component lt = LessThan(254);
    lt.in[0] <== value;
    lt.in[1] <== max_value;
    lt.out === 1;
}
```

A malicious prover submits `value = p + actual_value`. In the field, this equals `actual_value` (passes downstream arithmetic), but the bit decomposition may differ, causing `LessThan` to produce an incorrect result.

## Mitigations

- Never use `Num2Bits(254)` or any bit width that equals or exceeds the field's bit length; use `Num2Bits(253)` or smaller to guarantee canonical decomposition.
- Add explicit range checks that constrain inputs to be less than `p` when full-field-width operations are unavoidable.
- Audit all bit decomposition templates and comparison circuits for aliasing; values that are equal in the field can produce different bit patterns at full width.
- Document the prime field size and its implications at the top of every circuit file to prevent accidental full-width decompositions.
