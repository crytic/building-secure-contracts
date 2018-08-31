# Integer Overflow

It is possible to cause `add` and `sub` to overflow (or underflow) on any type of integer in Solidity.  

## Attack Scenarios

- Attacker has 5 of some ERC20 token. They spend 6, but because the token doesn't check for underflows,
they wind up with 2^256 tokens.

- A contract contains a dynamic array and an unsafe `pop` method. An attacker can underflow the length of
the array and alter other variables in the contract.

## Mitigations

- Use openZeppelin's safeMath library
- Validate all arithmetic

## Examples

## References

- https://github.com/OpenZeppelin/openzeppelin-solidity/blob/master/contracts/math/SafeMath.sol
- https://github.com/Arachnid/uscc/tree/master/submissions-2017/doughoyte
