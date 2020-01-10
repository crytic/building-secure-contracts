# Program Analysis

The following describes three different program analysis techniques that can be used to secure smart contracts.

- [Program Analysis Techniques](#program-analysis-techniques): High-level introduction to the tools
- [Echidna](./echidna): Introduction to fuzzing and exercises.
- [Slither](./slither): Introduction to static analysis and exercises.
- [Manticore](./manticore): : Introduction to symbolic execution and exercises.
- [Determining Properties](./determine-properties.md): What components can be tested and verified.

## Program Analysis Techniques

We are going to see how to use three distinctive testing and program analysis techniques:

- **Static analysis with [Slither](https://github.com/crytic/slither).** All the paths of the program are approximated and analyzed at the same time, through different program presentations (e.g. control-flow-graph)
- **Fuzzing with [Echidna](https://github.com/crytic/echidna).** The code is executed with a pseudo-random generation of transactions. The fuzzer will try to find a sequence of transactions to violate a given property.
- **Symbolic execution with [Manticore](https://github.com/trailofbits/manticore).** A formal verification technique, which translates each execution path to a mathematical formula, on which on top constraints can be checked.

Each technique has advantages and pitfalls, and will be useful in [specific cases](./determine-properties.md):

Technique | Tool | Usage | Speed | Bugs missed | False Alarms
--- | --- | --- | --- | --- | --- 
Static Analysis | Slither  | Cli & Scripts  | **Second** | ++ | +
Fuzzing | Echidna  | Solidity properties  | Minutes | + | **No**
Symbolic Execution | Manticore  | Solidity properties & Scripts | Minutes, hours | **No*** | **No**

\* if all the paths are explored without timeout

**Slither** will analyze your contract within a second. The tool has two modes: 

- (1)  from the command line: run the [inbuilt detectors](https://github.com/crytic/slither#detectors) to catch bugs without user-configuration.

- (2) from the API: write user-defined checks.

Static analysis might lead to false alarms and will be less suitable for complex checks (e.g. arithmetic checks). [crytic.io](https://crytic.io/) will give you access to private Sliher's detectors and GitHub integration.

**Echidna** will need to run for several minutes and will lead to zero false alarms. Echidna will check user-provided properties, written in Solidity. As it is based on random exploration, it might miss bugs.

**Manticore** is the heaviest technology. Manticore will verify user-provided properties. It will need a long run, but can be able to prove the validity of a property, and will lead to zero false alarms.


**Suggested workflow:** A good way to approach these techniques is to start with inbuilt detectors with Slither cli, to ensure that no simple bugs are present and/or will be introduced. Slither is the tool to use to check properties related to inheritances, variables dependencies, or structural issues. At the same time that the codebase grows, Echidna can be used to build more complex properties to be checked. For example, Echidna will help to check state-machine based properties. Custom checks can then be built with Slither. For example, the framework will provide protections lacking by Solidity (i.e. protecting a function to be overridden. Finally, Manticore should be used as a targeted tool, to verify a particular piece of code. For example, Manticore is a perfect fit to verify arithmetic operations.

### To summarize

- Use Slither cli as soon as you start your development process to catch early issues.

- Use Echidna as soon as you can determine a property of your contract.

- Use Slither to write custom static checks.

- Use Manticore once you want to reach an in-depth level of confidence in your code.

Read our recommendations [on how to determine the properties](./determine-properties.md) of your contracts to know what tool will be the best fit to test a component.

Writing clear code and following the coding best practices is a key point to write secure contracts. It will also help to identify what in the code needs to be tested. Follow our [development guideline](../development-guidelines) to ensure safer development.

**Note on unit tests**. Unit tests (and variants) are needed to build software with high quality. However, these techniques are not the best suited to find security flaws.  Their main limitation is to be usually used to test positive behaviors of code (i.e. the code works as expected in the normal context), while security flaws tend to reside in all the edge-cases that the developers did not think about.


