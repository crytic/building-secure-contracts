# Variable Shadowing

## Principle
- Variable shadowing occurs when a variable declared within a certain scope (decision block, method, or inner class)
has the same name as a variable declared in an outer scope.

## Attack
This depends a lot on the code of the contract itself. For instance, in the state_inherance.sol example, 
it stops the owner to perform the self-destruction of the contract.

## Mitigation
The solidity compiler has [some checks](https://github.com/ethereum/solidity/issues/973) to emit warnings when 
it detects this kind of issue, but [it has known examples](https://github.com/ethereum/solidity/issues/2563) where 
it fails.
