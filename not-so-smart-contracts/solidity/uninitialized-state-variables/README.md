## Uninitialized state variables

### Description
Usage of uninitialized state variables.

### Exploit Scenario:

```solidity
contract Uninitialized{
    address destination;

    function transfer() payable public{
        destination.transfer(msg.value);
    }
}
```
Bob calls `transfer`. As a result, the ethers are sent to the address 0x0 and are lost.


### Mitigations
- Initialize all the variables. If a variable is meant to be initialized to zero, explicitly set it to zero.
- Use [Slither](https://github.com/crytic/slither/) or [crytic.io](https://crytic.io/) to detect the issue



