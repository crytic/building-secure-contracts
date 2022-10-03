# Contracts can be forced to receive ether

In certain circunstances, contracts can be forced to receive ether without triggering any code. This should be considered by the contract developers in order to avoid breaking important invariants in their code.

## Attack Scenario

An attacker can use a specially crafted contract to forceful send ether using `suicide` / `selfdestruct`:

```solidity
contract Sender {
  function receive_and_suicide(address target) payable {
    suicide(target);
  }
}
```

## Example

- The MyAdvancedToken contract in [coin.sol](coin.sol#L145) is vulnerable to this attack. It will stop the owner to perform the migration of the contract.

## Mitigations

There is no way to block the reception of ether. The only mitigation is to avoid assuming how the balance of the contract
increases and implement checks to handle this type of edge cases.

## References

- https://solidity.readthedocs.io/en/develop/security-considerations.html#sending-and-receiving-ether
