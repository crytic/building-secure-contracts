# Underconstrained ZK Circuits

Insufficient constraints in zero-knowledge circuits allow a malicious prover to forge proofs for false statements.

## Description

Zero-knowledge proof circuits require that every witness value is fully determined by the
constraints. When constraints are insufficient, a malicious prover can supply witness values that
satisfy the circuit but do not match the intended computation. This breaks soundness -- the verifier
accepts a proof for a false statement.

Three common sub-patterns produce underconstrained circuits. First, **missing range checks**: when
an integer is cast to a finite field element without bounding it, the prover can submit
`FIELD_ORDER + x` which wraps to `x`, bypassing validation logic that depends on the original
magnitude. Second, **underconstrained witnesses**: a circuit assigns a value (e.g., a quotient) but
does not add enough constraints to pin it to a unique solution, so the prover can substitute a
different value that still satisfies the weak constraint. Third, **incorrect equality assertions**:
the circuit computes whether `A == B` into a variable but never constrains that variable to equal 1,
so the equality is checked but not enforced.

## Exploit Scenario

Alice deploys a ZK rollup that uses a division gadget to verify token distribution ratios on-chain. The circuit computes `out = input / divisor` and constrains `input == divisor * out + remainder` with a range check on `remainder`, but omits the range check on `out`. Bob, a malicious prover, sets `out` to `FIELD_ORDER + true_quotient`, which wraps to the same field element and satisfies the constraint. Bob submits a proof claiming a fraudulent distribution ratio, the verifier accepts it, and Bob withdraws more tokens than he is entitled to.

## Example

A division gadget that computes `out = input / divisor` using a remainder check, but omits the
range check on `out`. The prover can use a field-wrapped value instead of the true integer quotient.

```pseudocode
// Circuit: integer division gadget
// Assigns witness values (prover-controlled)
witness input, divisor, out, remainder

// Constraint: input == divisor * out + remainder
assert input == divisor * out + remainder

// Constraint: remainder < divisor  (range-checked)
assert_range(remainder, 0, divisor - 1)

// BUG: no range check on 'out'
// A malicious prover can set:
//   out       = FIELD_ORDER + true_quotient   (wraps to true_quotient in the field)
//   remainder = (recomputed to satisfy the first constraint)
// The constraints pass, but 'out' does not represent the real integer quotient.
```

A separate but equally dangerous variant occurs with equality assertions. The circuit
computes whether two values are equal, but the result is never enforced:

```pseudocode
// Circuit: verify a user-provided value matches a commitment
witness committed_value, user_value

// Assigns is_eq = 1 if equal, 0 otherwise
is_eq = compute_is_equal(committed_value, user_value)

// BUG: is_eq is computed but never constrained to 1
// The prover can set user_value to anything -- the circuit
// calculates is_eq = 0 but never rejects it.
```

## Mitigations

- Add explicit range checks on every witness value, especially outputs of division and modular arithmetic gadgets
- Distinguish assignments from constraints: every value the prover supplies must be pinned by at least one constraint that rejects all other values
- Constrain the output of every comparison and equality computation to equal the expected boolean result (e.g., `assert is_equal == 1`)
- Use formal verification tools to confirm that each witness is uniquely determined by public inputs and constraints
- Audit for field-wrapping by checking that all integer-to-field conversions are bounded below `FIELD_ORDER`
