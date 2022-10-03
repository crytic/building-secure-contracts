# Integer Overflow

It is possible to cause `add` and `sub` to overflow (or underflow) on any type of integer in Solidity.  

## Attack Scenarios

- Attacker has 5 of some ERC20 token. They spend 6, but because the token doesn't check for underflows,
they wind up with 2^256 tokens.

- A contract contains a dynamic array and an unsafe `pop` method. An attacker can underflow the length of
the array and alter other variables in the contract.

## Mitigations

- Use openZeppelin's [safeMath library](https://github.com/OpenZeppelin/openzeppelin-solidity/blob/master/contracts/math/SafeMath.sol)
- Validate all arithmetic

## Examples

- In [integer_overflow_1](interger_overflow_1.sol), we give both unsafe and safe version of
the `add` operation.

- [A submission](https://github.com/Arachnid/uscc/tree/master/submissions-2017/doughoyte) to the Underhanded Solidity Coding Contest that explots the unsafe dynamic array bug outlined above

