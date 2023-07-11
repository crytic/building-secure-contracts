# Signature Replay Protection

The StarkNet account abstraction model enables offloading many authentication details to contracts, providing a higher degree of flexibility. However, this also means that signature schemes must be designed with great care. Signatures should be resistant to replay attacks and signature malleability. They must include a nonce and preferably have a domain separator to bind the signature to a specific contract and chain. For instance, this prevents testnet signatures from being replayed against mainnet contracts.

## Example

Consider the following function that validates a signature for EIP712-style permit functionality. The first version lacks both a nonce and a method for identifying the specific chain a signature is designed for. Consequently, this signature schema would allow signatures to be replayed both on the same chain and across different chains, such as between a testnet and mainnet.

```cairo
    # TODO
```

## Mitigations

- Consider using the [OpenZeppelin Contracts for Cairo Account contract](https://github.com/OpenZeppelin/cairo-contracts/blob/main/docs/modules/ROOT/pages/accounts.adoc) or another existing account contract implementation.

## External Examples
