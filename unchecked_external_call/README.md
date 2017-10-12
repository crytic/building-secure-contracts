# Unchecked External Call

## Principle

- Certain Solidity operations, known as "external calls", require the developer to manually ensure that the operation succeeded. This is in contrast to operations which throw an exception on failure.
- Contracts which use external calls and do not check for success will likely be buggy, and may also be exploitable.

## Attack

- A contract uses an unchecked `address.send()` external call to transfer Ether.
- An attacker can reliably can cause this external call to fail 
- The consequences of this external call failing will be contract specific.
	- In the case of the King of the Ether contract, this resulted in accidental loss of Ether for some contract users, due to refunds not being sent.

## Known Exploit

- [King of the Ether](https://www.kingoftheether.com/postmortem.html)

## Further Resources

- http://solidity.readthedocs.io/en/develop/types.html#members-of-addresses
- https://github.com/ConsenSys/smart-contract-best-practices#handle-errors-in-external-calls
