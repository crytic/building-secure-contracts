# Missing constructor

## Principle
- Wrong constructor name

## Attack
Anyone can call the function that was supposed to be the constructor.
As a result anyone can change the state variables initialized in this function.

## Known exploit
[Rubixi](https://etherscan.io/address/0xe82719202e5965Cf5D9B6673B7503a3b92DE20be#code)
- See `Rubixi_source_code/Rubixi.sol`: `DynamicPyramid` instead of `Rubixi`
