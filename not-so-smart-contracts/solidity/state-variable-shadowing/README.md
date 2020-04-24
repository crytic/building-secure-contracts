## State variable shadowing

### Description
State variables can be shadowed in Solidity.

### Exploit Scenario:

```solidity
contract BaseContract{
    address owner;

    modifier isOwner(){
        require(owner == msg.sender);
        _;
    }

}

contract DerivedContract is BaseContract{
    address owner;

    constructor(){
        owner = msg.sender;
    }

    function withdraw() isOwner() external{
        msg.sender.transfer(this.balance);
    }
}
```
`owner` of `BaseContract` is never assigned and the modifier `isOwner` does not work.

### Mitigations
- Avoid state variable shadowing.
- Use [Slither](https://github.com/crytic/slither/) or [crytic.io](https://crytic.io/) to detect the issue


