# Contracts can be forced to receive ether

## Principle
- In certain circunstances, contracts can be forced to receive ether without triggering any code. This should be considered by the contract developers
in order to avoid breaking important invariants in their code.

## Attack

An attacker can use a specially crafted contract to forceful send ether using `suicide` / `selfdestruct`:

```solidity
contract Sender {
  function receive_and_suicide(address target) payable {
    suicide(target);
  }
}
```

The effects of this attack depend a lot on the code of the target contract. For instance, in the coin.sol example, 
it stops the owner to perform the migration of the contract.

## Mitigation

There is no way to block the reception of ether. The only mitigation is to avoid assuming how the balance of the contract
increases and implement checks to handle this type of edge cases.
