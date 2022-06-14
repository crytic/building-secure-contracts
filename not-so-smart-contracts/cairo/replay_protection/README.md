# Signature replay protection

The StarkNet account abstraction model allows a lot of the details of authentication to be offloaded to contracts. This provides a greater amount of flexibility, but that also means signature schemas need to be constructed with great care. Signatures must be resilient to replay attacks and signature malleability. Signatures must include a nonce and should have a domain separator to bind the signature to a particular contract and chain, so for example testnet signatures can't be replayed against mainnet contracts.

## Example

Consider the following function that validates a signature for EIP712-style permit functionality. The first version includes neither a nonce, nor a way of identifying the specific chain a signature is for. This signature schema would allow signatures to be replayed both on the same chain, but also across chains, for example between a testnet and mainnet.

```cairo
    # TODO
```

## Mitigations

- Consider using the [OpenZeppelin Contracts for Cairo Account contract](https://github.com/OpenZeppelin/cairo-contracts/blob/main/docs/Account.md) or another existing account contract implementation.

## External Examples

