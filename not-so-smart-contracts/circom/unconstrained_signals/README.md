# Unconstrained Signal Assignments

In Circom, the `<--` operator assigns a value to a signal but does **not** add an R1CS constraint. Only `<==` (which combines `<--` and `===`) adds a constraint. Similarly, Circom's `assert` keyword checks a condition at proof generation time but does **not** produce a constraint in the R1CS system — a malicious prover can patch their binary to skip asserts entirely. The only way to enforce a relationship in the proof is through `===` (constraint equality).

This is the most fundamental Circom pitfall. Developers use `<--` for complex computations where the full expression cannot be written as a single quadratic constraint, intending to add constraints later — but forget to do so. The result is a signal the prover can set to any value.

## Example

A template that computes an integer square root. The developer uses `<--` to assign the result (since `sqrt` is not a native Circom operation), and uses `assert` to check the result, but neither creates a constraint:

```circom
template Sqrt() {
    signal input in;
    signal output out;

    // BUG: <-- assigns but does not constrain
    out <-- compute_sqrt(in);

    // BUG: assert checks at proof-gen time, not in the constraint system
    assert(out * out == in);
}
```

A malicious prover can set `out` to any value — the assert runs in their local binary (which they control) and no R1CS constraint enforces `out * out == in`.

The fix is to replace the `assert` with a `===` constraint:

```circom
template Sqrt() {
    signal input in;
    signal output out;

    out <-- compute_sqrt(in);

    // Adds an actual R1CS constraint
    out * out === in;
}
```

## Mitigations

- Use `<==` instead of `<--` whenever the expression can be written as a single quadratic constraint; reserve `<--` only for non-quadratic computations and always pair it with explicit `===` constraints.
- Never rely on `assert` to enforce proof soundness — `assert` only runs at proof generation time and does not produce R1CS constraints; use `===` for all proof-critical checks.
- Audit every `<--` assignment to confirm a corresponding `===` constraint fully pins the signal's value.
- Use static analysis tools or constraint counters to flag signals that receive assignments but no constraints.
