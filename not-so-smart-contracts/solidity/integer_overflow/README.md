# Integer Overflow

It is possible to cause solidity's native `+` and `-` operators to overflow (or underflow) on any type of integer in Solidity versions <0.8.0 or within `unchecked` blocks of solidity >=0.8.0

## Attack Scenarios

- Attacker has 5 of some ERC20 token. They spend 6, but because the token doesn't check for underflows, they wind up with 2^256 tokens.

- A contract contains a dynamic array and an unsafe `pop` method. An attacker can underflow the length of the array and alter other variables in the contract.

## Mitigations

- Use solidity >=0.8.0 and use `unchecked` blocks carefully and only where required.
- If using solidity <0.8.0, use OpenZeppelin's [SafeMath library](https://github.com/OpenZeppelin/openzeppelin-solidity/blob/master/contracts/math/SafeMath.sol) for arithmetic.
- Validate all arithmetic with both manual review and property-based fuzz testing.

## Examples

- In [Overflow](Overflow.sol), we give both unsafe and safe version of the `add` operation.

- [A submission](https://github.com/Arachnid/uscc/tree/master/submissions-2017/doughoyte) to the Underhanded Solidity Coding Contest that exploits the unsafe dynamic array bug outlined above
