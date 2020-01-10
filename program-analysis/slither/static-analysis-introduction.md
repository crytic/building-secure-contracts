
# Introduction to static analysis

Slither is a static analysis framework, we described it in our previous blog posts ([1](https://blog.trailofbits.com/2018/10/19/slither-a-solidity-static-analysis-framework/), [2](https://blog.trailofbits.com/2019/05/27/slither-the-leading-static-analyzer-for-smart-contracts/)) and [academic paper](https://github.com/trailofbits/publications/blob/master/papers/wetseb19.pdf).

Static analysis exists in different flavors. Its application that you are the most likely to use is done by compilers (clang, etc.), but it is also what is used by bug finders (Infer, CodeClimate, x) and tools based on formal methods (Frame-C, Polyspace, etc.).

Doing a thorough introduction to static analysis is out of scope. We will focus here on the notions needed to understand how Slither works and how to use it.

- [Code representation](#code-representation)
- [Code analysis](#analysis)
- [Intermediate representation](#intermediate-representation)

## Code representation

In contrast to a dynamic analysis, which reasons on a single execution path, static analysis reasons about all the paths at once. To do so, it relies on different code representation. The two most common ones are the abstract syntax tree (AST), and the control flow graph (CFG).

### Abstract Syntax Trees

AST are used every time the compiler will perform a code parsing, and is probably the most basic structure on top of which static analysis can be performed.

In a nutshell, an AST is a structured tree where, usually, each leaf contains a variable or a constant, and internal nodes are operands or control flow operations. Consider the following code: 

```solidity
function safeAdd(uint a, uint b) pure internal returns(uint){
    if(a + b <= a){
        revert();
    }
    return a + b;
}
```

The corresponding AST is shown in:

![AST](./images/ast.png)

Slither uses the AST exported by solc.

While simple to build, AST is a nested structure, as a result it is not the most straightforward to analyze. For example to know the operations used by the expression `a + b <= a`, it requires to first analyze `<=` and then `+`. A common approach is to use the so-called visitor pattern, which navigates through the tree recursively. Slither contains a generic visitor in [`ExpressionVisitor`](https://github.com/crytic/slither/blob/master/slither/visitors/expression/expression.py).

The following code use the `ExpressionVisitor` to detect if the expression contains an addition:

```python
from slither.visitors.expression.expression import ExpressionVisitor
from slither.core.expressions.binary_operation import BinaryOperationType

class HasAddition(ExpressionVisitor):

    def result(self):
        return self._result

    def _post_binary_operation(self, expression):
        if expression.type == BinaryOperationType.ADDITION:
            self._result = True

visitor = HasAddition(expression) # expression is the expression to be tested
print(f'The expression {expression} has a addition: {visitor.result()}')
```

## Control flow graph

The second most known code representation is the control-flow-graph (CFG). As its name suggests, it is a graph-based representation, which exposes all the execution paths. Each node contains one or multiple instructions. Edges in the graph represent the control flow operations (if/then/else, loop, etc). The CFG or our previous example is:

![CFG](./images/cfg.png)

The CFG is the representation on top of which most of the analyses are built.

Many other code representations exist, each representation has advantages and drawbacks, according to the analysis you want to perform.

## Analysis
The simplest type of analysis you can do with Slither are syntactic analysis. 

### Syntax analysis

Slither can navigate through the different components of the code and their representation, to find inconsistencies and flaws using a pattern matching-like approach.

For example the following detectors only look for syntax-related issues:

- [State variables shadowing](https://github.com/crytic/slither/wiki/Detector-Documentation#state-variable-shadowing): the detector iterates over all the state variables, and check if one shadows a variable from an inherited contract ([state.py#L51-L62](https://github.com/crytic/slither/blob/0441338e055ab7151b30ca69258561a5a793f8ba/slither/detectors/shadowing/state.py#L51-L62))

- [Incorrect ERC20 interface](https://github.com/crytic/slither/wiki/Detector-Documentation#incorrect-erc20-interface): the detector looks for incorrect ERC20 functions signature ([incorrect_erc20_interface.py#L34-L55](https://github.com/crytic/slither/blob/0441338e055ab7151b30ca69258561a5a793f8ba/slither/detectors/erc/incorrect_erc20_interface.py#L34-L55))

### Semantic analysis
In contrast to syntax analysis, a semantic analysis will go deeper and analyze the “meaning” of the code. This family includes a broad types of analyses. They lead to more powerful results, but are also more complex to write. 

None of the exercises provided in this repository requires to understand the following, and semantic analysis will only be needed for advanced usages.

**Data dependency analysis**

A variable `variable_a` is said to be data-dependent of `variable_b`, if there is a path for which `variable_a`’s value is influenced by `variable_b`'s one.
In the following code, `variable_a` is dependent of `variable_b`:

```solidity
// ...
variable_a = variable_b + 1;
```

Slither comes with inbuilt [data dependency](https://github.com/crytic/slither/wiki/data-dependency) capacities, thanks to its intermediate representation (we will see the intermediate representation in the next section).

An example of data dependency usage can be found in the [dangerous strict equality detector](https://github.com/crytic/slither/wiki/Detector-Documentation#dangerous-strict-equalities). Here Slither will look for strict equality comparison to a dangerous value ([incorrect_strict_equality.py#L86-L87](https://github.com/crytic/slither/blob/6d86220a53603476f9567c3358524ea4db07fb25/slither/detectors/statements/incorrect_strict_equality.py#L86-L87)), and will inform the user that it should use `>=` or `<=` rather than `==`, to prevent an attacker to trap the contract. Among other, the detector will consider as dangerous the return value of a call to balanceOf(address) ([incorrect_strict_equality.py#L63-L64](https://github.com/crytic/slither/blob/6d86220a53603476f9567c3358524ea4db07fb25/slither/detectors/statements/incorrect_strict_equality.py#L63-L64)), and will use the data dependency engine to track it usage.

**Fix-point computation**

If your analysis navigates through the CFG, and follow the edges, you are likely to see already visited nodes. For example, if a loop is present as shown below:

```solidity
for(uint i; i < range; ++){
    variable_a += 1
}
```

Your analyze will need to know how to stop. There are two main strategies here: (1) iterate on each node a finite number of times, (2) compute a so-called *fixpoint*. A fixpoint basically means that analyzing this node does not provide any meaningful information. 

An example of fixpoint used can be found in the reentrancy detectors: Slither explores the nodes, and look for externals calls, write and read to storage. Once it has reached a fixpoint ([reentrancy.py#L125-L131](https://github.com/crytic/slither/blob/master/slither/detectors/reentrancy/reentrancy.py#L125-L131)), it stops the exploration, and analyze the results to see if a reentrancy is present, through different reentrancy patterns ([reentrancy_benign.py](https://github.com/crytic/slither/blob/b275bcc824b1b932310cf03b6bfb1a1fef0ebae1/slither/detectors/reentrancy/reentrancy_benign.py), [reentrancy_read_before_write.py](https://github.com/crytic/slither/blob/b275bcc824b1b932310cf03b6bfb1a1fef0ebae1/slither/detectors/reentrancy/reentrancy_read_before_write.py), [reentrancy_eth.py](https://github.com/crytic/slither/blob/b275bcc824b1b932310cf03b6bfb1a1fef0ebae1/slither/detectors/reentrancy/reentrancy_eth.py)).

Writing analyses using efficient fixpoint computation requires a good understanding of how the analysis propagates its information.

## Intermediate representation

An intermediate representation (IR) is a language meant to be more amenable to static analysis than the original one. Slither translate Solidity to its IR: [SlithIR](https://github.com/crytic/slither/wiki/SlithIR).

If you only want to write basic checks, understanding slithIR is not needed. But it will come in handy if you plan to write advance semantic analysis. The [SlithIR](https://github.com/crytic/slither/wiki/Printer-documentation#slithir) and the [SSA](https://github.com/crytic/slither/wiki/Printer-documentation#slithir-ssa) printers will help you to understand how the code is translated.
