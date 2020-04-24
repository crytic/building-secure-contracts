## Tautology or contradiction

### Description
Expressions that are tautologies or contradictions.

### Exploit Scenario:

```solidity
contract A {
	function f(uint x) public {
		// ...
        if (x >= 0) { // bad -- always true
           // ...
        }
		// ...
	}

	function g(uint8 y) public returns (bool) {
		// ...
        return (y < 512); // bad!
		// ...
	}
}
```
`x` is an `uint256`, as a result `x >= 0` will be always true.
`y` is an `uint8`, as a result `y <512` will be always true.  


### Mitigations
- Avoid tautology
- Use [Slither](https://github.com/crytic/slither/) or [crytic.io](https://crytic.io/) to detect the issue

