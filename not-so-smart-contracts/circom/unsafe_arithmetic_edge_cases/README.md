# Unsafe Arithmetic Edge Cases

Circom arithmetic operates over a prime field where all values are unsigned integers modulo p. This creates several edge cases that break developer expectations. First, **division by zero**: Circom does not abort on division by zero — the result is undefined and the prover can supply any value. Second, **signed comparison semantics**: the `LessThan` and `GreaterThan` templates use bit decomposition and interpret values as unsigned, but field elements near p/2 can behave counterintuitively since p-1 (representing -1) decomposes to a large bit pattern. Third, **non-deterministic division**: the `/` operator in signal assignments computes the modular inverse, so `1 / 2` does not equal 0 — it equals `(p+1)/2`, the modular inverse of 2. Developers expecting integer division semantics get silently wrong results.

## Example

A coordinate conversion template divides by an input value without checking for zero:

```circom
template ConvertCoordinates() {
    signal input x;
    signal input y;
    signal input z;
    signal output out_x;
    signal output out_y;

    // BUG: if z == 0, division is undefined
    // Prover can set out_x and out_y to any value
    out_x <-- x / z;
    out_y <-- y / z;

    // These constraints pass for ANY out_x, out_y when z == 0
    out_x * z === x;
    out_y * z === y;
}
```

When `z = 0`, the constraints become `out_x * 0 === 0` and `out_y * 0 === 0`, which hold for any `out_x` and `out_y` — the prover can output arbitrary coordinates. Fix: constrain `z` to be nonzero:

```circom
template ConvertCoordinates() {
    signal input x;
    signal input y;
    signal input z;
    signal output out_x;
    signal output out_y;

    // FIX: enforce z != 0 via inverse witness
    signal z_inv;
    z_inv <-- 1 / z;
    z_inv * z === 1;  // Fails if z == 0 (no inverse exists)

    out_x <-- x / z;
    out_y <-- y / z;
    out_x * z === x;
    out_y * z === y;
}
```

## Mitigations

- Always constrain divisors to be nonzero by requiring the prover to supply a multiplicative inverse (`z_inv * z === 1`)
- Never assume integer division semantics — Circom `/` computes modular inverses, producing unexpected results for even divisors
- Use explicit range constraints when comparison templates must handle values that could exceed p/2, to prevent signed-interpretation ambiguities
- Audit all arithmetic for zero-edge-case behavior: when any input to a multiplication is zero, constraints involving that product become trivially satisfiable
