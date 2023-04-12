# Introduction to Dynamic Symbolic Execution

[Manticore]() is a dynamic symbolic execution tool, as described in our previous blog posts ([1](https://blog.trailofbits.com/2017/04/27/manticore-symbolic-execution-for-humans/), [2](https://blog.trailofbits.com/2017/05/15/magic-with-manticore/), [3](https://blog.trailofbits.com/2017/05/15/magic-with-manticore/), [4](https://blog.trailofbits.com/2017/05/15/magic-with-manticore/)).

## A Brief Overview of Dynamic Symbolic Execution

Dynamic Symbolic Execution (DSE) is a program analysis technique that explores a state space with a high degree of semantic awareness. This technique is based on discovering "program paths," represented as mathematical formulas called `path predicates`. Conceptually, DSE operates on path predicates in two steps:

1. They are constructed using constraints on the program's input.
2. They are used to generate program inputs that will cause the associated paths to execute.

This approach produces no false positives, meaning that all identified program states can be triggered during concrete execution. For example, if the analysis finds an integer overflow, it is guaranteed to be reproducible.

### Path Predicate Example

To understand how DSE works, consider the following example:

```solidity
function f(uint256 a) {
    if (a == 65) {
        // A bug is present
    }
}
```

Since `f()` contains two paths, DSE will construct two different path predicates:

- Path 1: `a == 65`
- Path 2: `Not (a == 65)`

Each path predicate is a mathematical formula that can be given to an `SMT solver`, which will try to solve the equation. For `Path 1`, the solver will say that the path can be explored with `a = 65`. For `Path 2`, the solver can give `a` any value other than 65, for example `a = 0`.

### Verifying Properties

Manticore provides full control over the execution of each path, allowing arbitrary constraints to be added to almost anything. This control enables the creation of properties on the contract.

Consider the following example:

```solidity
function unsafe_add(uint256 a, uint256 b) returns (uint256 c) {
    c = a + b; // no overflow protection
    return c;
}
```

There is only one path to explore in this function:

- Path 1: `c = a + b`

Using Manticore, you can check for overflow and add constraints to the path predicate:

- `c = a + b AND (c < a OR c < b)`

If it is possible to find a valuation of `a` and `b` for which the path predicate above is feasible, it means that you have found an overflow. For example, the solver can generate the input `a = 10 , b = MAXUINT256`.

Consider a fixed version of this function:

```solidity
function safe_add(uint256 a, uint256 b) returns (uint256 c) {
    c = a + b;
    require(c >= a);
    require(c >= b);
    return c;
}
```

The formula associated with this version would include an overflow check:

- `c = a + b AND (c >= a) AND (c >= b) AND (c < a OR c < b)`

This formula cannot be solved, which serves as a **proof** that in `safe_add`, `c` will always increase.

DSE is thus a powerful tool that can verify arbitrary constraints on your code.
