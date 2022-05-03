# Signature replay protection

The StarkNet account abstraction model allows a lot of the details of authentication to be offloaded to contracts. This provides a greater amount of flexibility, but that also means signature schemas need to be constructed with great care. Signatures must be resilient to replay attacks and signature malleability. Signatures must include a nonce and should have a domain separator to bind the signature to a particular contract and chain, so for example testnet signatures can't be replayed against mainnet contracts.

## Attack Scenarios



## Mitigations

- Consider using the [OpenZeppelin Contracts for Cairo Account contract](https://github.com/OpenZeppelin/cairo-contracts/blob/main/docs/Account.md) or another existing account contract implementation.

## Examples

