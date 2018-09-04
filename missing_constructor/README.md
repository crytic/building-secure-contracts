# Missing constructor

If the constructor of a smart contract is not present (or not spelled the same way as the contract name), it is callable by anyone.

## Attack
Anyone can call the function that was supposed to be the constructor.
As a result anyone can change the state variables initialized in this function.

## Mitigations

- Use `constructor` instead of a named constructor

## Examples
- [Rubixi](Rubixi_source_code/Rubixi.sol) uses `DynamicPyramid` instead of `Rubixi` as a constructor
- An [incorrectly named constructor](Missing.sol)
