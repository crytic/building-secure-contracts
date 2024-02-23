# Signature Replay Protection

The StarkNet account abstraction model enables offloading many authentication details to contracts, providing a higher degree of flexibility. However, this also means that signature schemes must be designed with great care. Signatures should be resistant to replay attacks and signature malleability. They must include a nonce and preferably have a domain separator to bind the signature to a specific contract and chain. For instance, this prevents testnet signatures from being replayed against mainnet contracts.

## Example

Consider the following function that validates a signature for EIP712-style permit functionality. Notice that the contract lacks a way of keeping track of nonces. As a result, the same signature can be replayed over and over again. In addition, there is no method for identifying the specific chain a signature is designed for. Consequently, this signature schema would allow signatures to be replayed both on the same chain and across different chains, such as between a testnet and mainnet.

```cairo
    #[storage]
    struct Storage {
        authorized_pubkey: felt252
    }

    #[derive(Hash)]
    struct Signature {
        sig_r: felt252,
        sig_s: felt252,
        amount: u256,
        recipient: ContractAddress
    }

    fn bad_is_valid_signature(self: @ContractState, sig: Signature) {
        let hasher = PoseidonTrait::new();
        let hash = hasher.update_with(sig).finalize();
        ecdsa::check_ecdsa_signature(hash,authorized_pubkey,sig.r,sig.s);
    }
```

## Mitigations

- Consider using the [OpenZeppelin Contracts for Cairo Account contract](https://github.com/OpenZeppelin/cairo-contracts/blob/main/docs/modules/ROOT/pages/accounts.adoc) or another existing account contract implementation.
