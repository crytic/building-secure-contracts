# Wrong Constructor Name

A function intended to be a constructor is named incorrectly, which causes it to end up in the runtime bytecode instead of being a constructor.

## Attack
Anyone can call the function that was supposed to be the constructor.
As a result anyone can change the state variables initialized in this function.

## Mitigations

- Use `constructor` instead of a named constructor

## Examples
- [Rubixi](Rubixi_source_code/Rubixi.sol) uses `DynamicPyramid` instead of `Rubixi` as a constructor
- An [incorrectly named constructor](incorrect_constructor.sol)
