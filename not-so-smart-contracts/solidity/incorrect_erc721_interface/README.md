## Incorrect erc721 interface

### Description
Incorrect return values for ERC721 functions. A contract compiled with solidity > 0.4.22 interacting with these functions will fail to execute them, as the return value is missing.

### Exploit Scenario:

```solidity
contract Token{
    function ownerOf(uint256 _tokenId) external view returns (bool);
    //...
}
```
`Token.ownerOf` does not return an address as ERC721 expects. Bob deploys the token. Alice creates a contract that interacts with it but assumes a correct ERC721 interface implementation. Alice's contract is unable to interact with Bob's contract.

### Mitigations
- Set the appropriate return values and value-types for the defined ERC721 functions.
- Use [Slither](https://github.com/crytic/slither/) or [crytic.io](https://crytic.io/) to detect the issue


