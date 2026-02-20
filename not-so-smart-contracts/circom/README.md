# (Not So) Smart Contracts (Circom)

This repository contains examples of common Circom circuit vulnerabilities, featuring patterns from real security audits. Utilize the Not So Smart Contracts to learn about Circom pitfalls, refer to them during security reviews, and use them as a benchmark for security analysis tools.

## Features

Each _Not So Smart Contract_ consists of a standard set of information:

- Vulnerability type description
- Attack scenarios to exploit the vulnerability
- Recommendations to eliminate or mitigate the vulnerability

## Vulnerabilities

| Not So Smart Contract                                                | Description                                                                        |
| -------------------------------------------------------------------- | ---------------------------------------------------------------------------------- |
| [Unconstrained Signal Assignments](unconstrained_signals)            | `<--` and `assert` do not produce R1CS constraints, leaving signals prover-controlled |
| [Field Overflow Aliasing](field_overflow_aliasing)                   | Full-field-width bit decompositions allow aliased values to bypass range checks     |
| [Unconstrained Component Outputs](unconstrained_component_outputs)   | Comparison component outputs computed but never constrained to expected values      |
| [Missing Input Constraints](missing_input_constraints)               | Templates assume boolean or range properties on inputs without enforcing them       |
| [Unsafe Arithmetic Edge Cases](unsafe_arithmetic_edge_cases)         | Division by zero, modular inverse semantics, and signed comparison pitfalls         |

## Credits

These examples are developed and maintained by **[Trail of Bits](https://www.trailofbits.com/)**.

If you have any questions, issues, or wish to learn more, join the #ethereum channel on the [Empire Hacking Slack](https://slack.empirehacking.nyc/) or [contact us](https://www.trailofbits.com/contact/) directly.
