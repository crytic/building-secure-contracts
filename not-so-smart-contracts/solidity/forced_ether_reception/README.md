# Contracts can be forced to receive ether

In certain circumstances, contracts can be forced to receive ether without triggering any code. This should be considered by the contract developers in order to avoid breaking important invariants in their code.

## Attack Scenario

An attacker can use a specially crafted contract to forceful send ether using `suicide` / `selfdestruct`:

```solidity
contract Sender {
  function receive_and_suicide(address target) payable {
    suicide(target);
  }
}
```

Alternatively, if a miner sets some contract as the block's `coinbase` then it's ether balance will be increased without executing any `fallback()` or `receive()` code that might be present.

## Example

- The MyAdvancedToken contract in [coin.sol](coin.sol#L145) is vulnerable to this attack. The owner will not be able to perform a migration of the contract if it receives ether outside of a call to `buy()`.

## Mitigations

There is no way to completely block the reception of ether. The only mitigation is to avoid assuming how the balance of the contract increases and implement checks to handle this type of edge cases.

## References

- [Solidity docs re sending & receiving ether](https://solidity.readthedocs.io/en/develop/security-considerations.html#sending-and-receiving-ether)
