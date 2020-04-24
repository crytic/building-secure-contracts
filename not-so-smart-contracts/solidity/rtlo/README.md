## Right-To-Left-Override character

### Description
An attacker can manipulate the logic of the contract by using a right-to-left-override character (U+202E)

### Exploit Scenario:

```solidity
contract Token
{

    address payable o; // owner
    mapping(address => uint) tokens;

    function withdraw() external returns(uint)
    {
        uint amount = tokens[msg.sender];
        address payable d = msg.sender;
        tokens[msg.sender] = 0;
        _withdraw(/*owner‮/*noitanitsed*/ d, o/*‭
		        /*value */, amount);
    }

    function _withdraw(address payable fee_receiver, address payable destination, uint value) internal
    {
		fee_receiver.transfer(1);
		destination.transfer(value);
    }
}
```

`Token` uses the right-to-left-override character when calling `_withdraw`. As a result, the fee is incorrectly sent to `msg.sender`, and the token balance is sent to the owner.



### Mitigations
- Special control characters must not be allowed.
- Use [Slither](https://github.com/crytic/slither/) or [crytic.io](https://crytic.io/) to detect the issue

