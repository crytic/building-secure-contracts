
## Uninitialized storage variables

### Description
An uinitialized storage variable will act as a reference to the first state variable, and can override a critical variable.

### Exploit Scenario:

```solidity
contract Uninitialized{
    address owner = msg.sender;

    struct St{
        uint a;
    }

    function func() {
        St st;
        st.a = 0x0;
    }
}
```
Bob calls `func`. As a result, `owner` is override to 0.


### Mitigations
- Initialize all the storage variables.
- Use [Slither](https://github.com/crytic/slither/) or [crytic.io](https://crytic.io/) to detect the issue


