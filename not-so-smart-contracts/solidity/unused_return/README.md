## Unused return


### Description
The return value of an external call is not checked.

### Exploit Scenario:

```solidity
contract MyConc{
    using SafeMath for uint;   
    function my_func(uint a, uint b) public{
        a.add(b);
    }
}
```
`MyConc` calls `add` of SafeMath, but does not store the result in `a`. As a result, the computation has no effect.

### Mitigations
- Ensure that all the return values of the function calls are used.
- Use [Slither](https://github.com/crytic/slither/) or [crytic.io](https://crytic.io/) to detect the issue


