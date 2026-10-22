# Missing Input Constraints

Templates that assume inputs are boolean or range-bound without enforcing constraints accept invalid values.

## Description

Circom templates often assume their inputs satisfy certain properties — such as being boolean (0 or 1), being within a specific range, or being valid curve points — without actually enforcing these assumptions with constraints. Since any field element can be passed as an input signal, a malicious prover can violate the assumption while still satisfying all explicit constraints in the circuit.

This is especially dangerous with logical gates: the `AND()` template computes `out <== a * b`, which only functions as a boolean AND when both `a` and `b` are 0 or 1. If a prover supplies `a = 2` and `b = 3`, the output is 6 — which is neither 0 nor 1 and breaks any downstream logic expecting a boolean. Similarly, curve-arithmetic templates that assume inputs are valid curve points (satisfying the curve equation) can produce incorrect results or allow forged proofs when fed arbitrary field elements.

## Exploit Scenario

Alice deploys a ZK-based access control circuit where two boolean flags (`has_role` and `is_active`) are ANDed together to produce an `allowed` signal. A downstream template grants access when `allowed != 0`. Bob, a malicious prover, supplies `has_role = 2` and `is_active = 3`, producing `allowed = 6`. Since no constraint enforces that the inputs are boolean, the proof verifies. The downstream nonzero check passes, and Bob gains access despite holding invalid credential values.

## Example

A circuit that computes the AND of two access flags, assuming both are boolean. A downstream template consumes the result and makes an access decision based on it:

```circom
template AccessCheck() {
    signal input has_role;
    signal input is_active;
    signal output allowed;

    // BUG: assumes has_role and is_active are boolean (0 or 1)
    // but no constraint enforces this
    allowed <== has_role * is_active;
}

template GrantAccess() {
    signal input role_flag;
    signal input active_flag;

    component check = AccessCheck();
    check.has_role <== role_flag;
    check.is_active <== active_flag;

    // Downstream logic: nonzero means access granted
    component nz = IsZero();
    nz.in <== check.allowed;
    nz.out === 0;  // requires allowed != 0
}
```

A prover can set `role_flag = 2, active_flag = 3`, producing `allowed = 6`. The `IsZero` check passes because 6 is nonzero, granting access despite the inputs being invalid booleans.

## Mitigations

- Add explicit boolean constraints (`x * (1 - x) === 0`) on every signal that is assumed to be 0 or 1
- Validate curve points with the curve equation constraint before passing them to curve-arithmetic templates
- Add range checks on inputs that must fall within a specific numeric range, using `Num2Bits` with an appropriate bit width
- Document the expected domain of every input signal in template comments, and enforce each assumption with a constraint
- Never rely on external callers to provide valid inputs — treat every template input as untrusted
