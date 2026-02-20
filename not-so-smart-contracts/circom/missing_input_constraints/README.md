# Missing Input Constraints

Circom templates often assume their inputs satisfy certain properties — such as being boolean (0 or 1), being within a specific range, or being valid curve points — without actually enforcing these assumptions with constraints. Since any field element can be passed as an input signal, a malicious prover can violate the assumption while still satisfying all explicit constraints in the circuit.

This is especially dangerous with logical gates: the `AND()` template computes `out <== a * b`, which only functions as a boolean AND when both `a` and `b` are 0 or 1. If a prover supplies `a = 2` and `b = 3`, the output is 6 — which is neither 0 nor 1 and breaks any downstream logic expecting a boolean. Similarly, curve-arithmetic templates that assume inputs are valid curve points (satisfying the curve equation) can produce incorrect results or allow forged proofs when fed arbitrary field elements.

## Example

A circuit that computes the AND of two access flags, assuming both are boolean:

```circom
template AccessCheck() {
    signal input has_role;
    signal input is_active;
    signal output allowed;

    // BUG: assumes has_role and is_active are boolean (0 or 1)
    // but no constraint enforces this
    allowed <== has_role * is_active;
}
```

A prover can set `has_role = 2, is_active = 3`, producing `allowed = 6`. Downstream templates that check `allowed === 1` would reject this, but templates that check `allowed != 0` (nonzero = true) would accept it even though the inputs are invalid. Fix: enforce boolean constraints on inputs:

```circom
template AccessCheck() {
    signal input has_role;
    signal input is_active;
    signal output allowed;

    // FIX: constrain inputs to be boolean
    has_role * (1 - has_role) === 0;
    is_active * (1 - is_active) === 0;

    allowed <== has_role * is_active;
}
```

## Mitigations

- Add explicit boolean constraints (`x * (1 - x) === 0`) on every signal that is assumed to be 0 or 1
- Validate curve points with the curve equation constraint before passing them to curve-arithmetic templates
- Add range checks on inputs that must fall within a specific numeric range, using `Num2Bits` with an appropriate bit width
- Document the expected domain of every input signal in template comments, and enforce each assumption with a constraint
- Never rely on external callers to provide valid inputs — treat every template input as untrusted
