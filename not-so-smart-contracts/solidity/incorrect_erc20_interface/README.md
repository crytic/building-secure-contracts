## Incorrect erc20 interface

### Description
Incorrect return values for ERC20 functions. A contract compiled with solidity > 0.4.22 interacting with these functions will fail to execute them, as the return value is missing.

### Exploit Scenario:

```solidity
contract Token{
    function transfer(address to, uint value) external;
    //...
}
```
`Token.transfer` does not return a boolean. Bob deploys the token. Alice creates a contract that interacts with it but assumes a correct ERC20 interface implementation. Alice's contract is unable to interact with Bob's contract.

### Recommendation
- Set the appropriate return values and value-types for the defined ERC20 functions.
- Use [Slither](https://github.com/crytic/slither/) or [crytic.io](https://crytic.io/) to detect the issue
- Use `slither-check-erc` to ensure ERC's conformance


