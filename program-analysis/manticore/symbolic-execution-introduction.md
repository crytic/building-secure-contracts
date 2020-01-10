# Introduction to dynamic symbolic execution

[Manticore]() is a dynamic symbolic execution tool, we described in our previous blogposts ([1](https://blog.trailofbits.com/2017/04/27/manticore-symbolic-execution-for-humans/), [2](https://blog.trailofbits.com/2017/05/15/magic-with-manticore/), [3](https://blog.trailofbits.com/2017/05/15/magic-with-manticore/), [4](https://blog.trailofbits.com/2017/05/15/magic-with-manticore/)).

## Dynamic Symbolic Execution in a Nutshell

Dynamic symbolic execution (DSE) is a program analysis technique that explores a state space with a high degree of semantic awareness. This technique is based on the discovery of "program paths", represented as mathematical formulas called `path predicates`. Conceptually,  this technique operates on path predicates in two steps: 

1. They are constructed using constraints on the program's input. 
2. They are used to generate program inputs that will cause the associated paths to execute.

This approach produces no false positives in the sense that all identified program states can be triggered during concrete execution. For example, if the analysis finds an integer overflow, it is guaranteed to be reproducible.

### Path Predicate Example
To get an insigh of how DSE works, consider the following example:

```solidity
function f(uint a){
  
  if (a == 65) {
      // A bug is present
  }
  
}
```

As `f()` contains two paths, a DSE will construct two differents path predicates:
- Path 1: `a == 65`
- Path 2: `Not (a == 65)`

Each path predicate is a mathematical formula that can be given to a so-called [SMT solver](https://github.com/trailofbits/building-secure-contracts/blob/master/program-analysis/determine-properties.md), which will try to solve the equation. For `Path 1`, the solver will say that the path can be explored with `a = 65`. For `Path 2`, the solver can give `a` any value other than 65, for example `a = 0`.

### Verifying properties
Manticore allows a full control over all the execution of each path. As a result, it allows to add arbirtray contraints to almost anything. This control allows for the creation of properties on the contract.

Consider the following example:

```solidity
function unsafe_add(uint a, uint b) returns(uint c){
  c = a + b; // no overflow protection
  return c;
}
```

Here there is only one path to explore in the function:
- Path 1: `c = a + b`

Using Manticore, you can check for overflow, and add constraitns to the path predicate:
- `c = a + b AND (c < a OR c < b)`

If it is possible to find a valuation of `a` and `b` for which the path predicate above is feasible, it means that you have found an overflow. For example the solver can generate the input `a = 10 , b = MAXUINT256`.

If you consider a fixed version:

```solidity
function safe_add(uint a, uint b) returns(uint c){
  c = a + b; 
  require(c>=a);
  require(c>=b);
  return c;
}
```

The associated formula with overflow check would be:
- `c = a + b AND (c >= a) AND (c=>b) AND (c < a OR c < b)`

This formula cannot be solved; in other world this is a **proof** that in `safe_add`, `c` will always increase.

DSE is thereby a powerful tool, that can verify arbitrary constraints on your code.
