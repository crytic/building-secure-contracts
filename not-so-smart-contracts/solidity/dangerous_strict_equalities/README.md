## Dangerous strict equalities

### Description
Use of strict equalities that can be easily manipulated by an attacker.

### Exploit Scenario:

```solidity
contract Crowdsale{
    function fund_reached() public returns(bool){
        return this.balance == 100 ether;
    }
```
`Crowdsale` relies on `fund_reached` to know when to stop the sale of tokens. `Crowdsale` reaches 100 ether. Bob sends 0.1 ether. As a result, `fund_reached` is always false and the crowdsale never ends.

### Mitigations
- Don't use strict equality to determine if an account has enough ethers or tokens.
- Use [Slither](https://github.com/crytic/slither/) or [crytic.io](https://crytic.io/) to detect the issue

