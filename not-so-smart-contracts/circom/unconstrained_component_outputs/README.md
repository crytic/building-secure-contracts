# Unconstrained Component Outputs

Comparison component outputs that are computed but never constrained do not enforce any check.

## Description

In Circom, components like `IsEqual()`, `LessThan()`, and `IsZero()` compute boolean output signals, but instantiating the component and wiring inputs is not enough — the caller must explicitly constrain the output. A common mistake is computing a comparison result into a signal and then either never reading it, or reading it without constraining it to the expected value. The component internally constrains its own logic, but the relationship between the component's output and the rest of the circuit only exists if the caller adds it.

This is subtle because the circuit compiles and generates valid proofs — the component works correctly in isolation. But if the output signal is not constrained to equal 1 (or 0), the proof does not actually enforce the intended check. A malicious prover can supply inputs that fail the comparison, and the proof still verifies because nothing requires the output to be any particular value.

## Exploit Scenario

Alice deploys a ZK credential verification circuit that uses `IsEqual()` to confirm a user's committed identity matches a registered value. The template wires both inputs into the `IsEqual` component but assigns `valid <== 1` unconditionally instead of constraining `eq.out === 1`. Bob, a malicious prover, submits a proof with mismatched identity values. Because `eq.out` is never constrained, the proof verifies successfully, and Bob gains access to resources belonging to another user.

## Example

A circuit checks that two committed values are equal, but never constrains the output of `IsEqual`:

```circom
template VerifyMatch() {
    signal input a;
    signal input b;
    signal output valid;

    component eq = IsEqual();
    eq.in[0] <== a;
    eq.in[1] <== b;

    // BUG: eq.out is computed but never constrained
    // A prover can submit a != b and the proof still verifies
    valid <== 1;
}
```

The `IsEqual` component correctly computes `eq.out = (a == b ? 1 : 0)`, but since `eq.out` is never used in a constraint, the circuit does not enforce equality.

## Mitigations

- Always constrain component outputs with `===` to enforce the intended boolean result; instantiating a component and wiring inputs is not sufficient.
- Treat comparison components (`IsEqual`, `LessThan`, `GreaterThan`, `IsZero`) as producing unconstrained signals until explicitly checked.
- Audit for "dead outputs" — component output signals that are assigned but never appear in a `===` constraint or `<==` assignment to another constrained signal.
- Use circuit analysis tools to detect signals with zero fan-out in the constraint graph.
