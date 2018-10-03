# Unchecked External Call

Certain Solidity operations known as "external calls", require the developer to manually ensure that the operation succeeded. This is in contrast to operations which throw an exception on failure. If an external call fails, but is not checked, the contract will continue execution as if the call succeeded. This will likely result in buggy and potentially exploitable behavior from the contract.

## Attack

- A contract uses an unchecked `address.send()` external call to transfer Ether.
- If it transfers Ether to an attacker contract, the attacker contract can reliably cause the external call to fail, for example, with a fallback function which intentionally runs out of gas.
- The consequences of this external call failing will be contract specific.
	- In the case of the King of the Ether contract, this resulted in accidental loss of Ether for some contract users, due to refunds not being sent.

## Mitigation

- Manually perform validation when making external calls
- Use `address.transfer()`

## Example

- [King of the Ether](https://www.kingoftheether.com/postmortem.html) (line numbers:
	[100](KotET_source_code/KingOfTheEtherThrone.sol#L100),
	[107](KotET_source_code/KingOfTheEtherThrone.sol#L107),
	[120](KotET_source_code/KingOfTheEtherThrone.sol#L120),
	[161](KotET_source_code/KingOfTheEtherThrone.sol#L161))

## References

- http://solidity.readthedocs.io/en/develop/security-considerations.html
- http://solidity.readthedocs.io/en/develop/types.html#members-of-addresses
- https://github.com/ConsenSys/smart-contract-best-practices#handle-errors-in-external-calls
- https://vessenes.com/ethereum-griefing-wallets-send-w-throw-considered-harmful/
