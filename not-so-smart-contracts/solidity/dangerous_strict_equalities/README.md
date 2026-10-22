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

`Crowdsale` relies on `fund_reached` to know when to stop the sale of tokens. If `Crowdsale` reaches 100 ether and Bob sends 0.1 ether, `fund_reached` is always false and the crowdsale would never end.

### Mitigations

- Don't use strict equality to determine if an account has sufficient ethers or tokens.
- Use [slither](https://github.com/crytic/slither/) to detect this issue.
