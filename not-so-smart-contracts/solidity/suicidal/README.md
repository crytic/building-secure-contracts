## Suicidal contract

### Description
Unprotected call to a function executing `selfdestruct`/`suicide`.

### Exploit Scenario:

```solidity
contract Suicidal{
    function kill() public{
        selfdestruct(msg.sender);
    }
}
```
Bob calls `kill` and destructs the contract.

### Mitigations
- Protect access to all sensitive functions.
- Use [Slither](https://github.com/crytic/slither/) or [crytic.io](https://crytic.io/) to detect the issue


