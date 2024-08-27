# Unsigned Transaction Validation

There are three types of transactions allowed in a Substrate runtime: signed, unsigned, and inherent. An unsigned transaction does not require a signature and does not include information about who sent the transaction. This is naturally problematic because there is no by-default deterrent to spam or replay attacks. Because of this, Substrate allows users to create custom functions to validate unsigned transaction. However, incorrect or improper validation of an unsigned transaction can allow _anyone_ to perform potentially malicious actions. Usually, unsigned transactions are allowed only for select parties (e.g., off-chain workers (OCW)). But, if improper data validation of an unsigned transaction allows a malicious actor to spoof data as if it came from an OCW, this can lead to unexpected behavior. Additionally, improper validation opens up the possibility to replay attacks where the same transaction can be sent to the transaction pool again and again to perform some malicious action repeatedly.

The validation of an unsigned transaction must be provided by the pallet that chooses to accept them. To allow unsigned transactions, a pallet must implement the [`frame_support::unsigned::ValidateUnsigned`](https://paritytech.github.io/substrate/master/frame_support/attr.pallet.html#validate-unsigned-palletvalidate_unsigned-optional) trait. The `validate_unsigned` function, which must be implemented as part of the `ValidateUnsigned` trait, will provide the logic necessary to ensure that the transaction is valid. An off chain worker (OCW) can be implemented directly in a pallet using the `offchain_worker` [hook](https://paritytech.github.io/substrate/master/frame_support/attr.pallet.html#hooks-pallethooks-optional). The OCW can send an unsigned transaction by calling [`SubmitTransaction::submit_unsigned_transaction`](https://paritytech.github.io/substrate/master/frame_system/offchain/struct.SubmitTransaction.html). Upon submission, the `validate_unsigned` function will ensure that the transaction is valid and then pass the transaction on towards towards the final dispatchable function.

# Example

The [`pallet-bad-unsigned`](https://github.com/crytic/building-secure-contracts/blob/master/not-so-smart-contracts/substrate/validate_unsigned/pallet-bad-unsigned.rs) pallet is an example that showcases improper unsigned transaction validation. The pallet tracks the average, rolling price of some "asset"; this price data is being retrieved by an OCW. The `fetch_price` function, which is called by the OCW, naively returns 100 as the current price (note that an [HTTP request](https://github.com/paritytech/substrate/blob/e8a7d161f39db70cb27fdad6c6e215cf493ebc3b/frame/examples/offchain-worker/src/lib.rs#L572-L625) can be made here for true price data). The `validate_unsigned` function (see below) simply validates that the `Call` is being made to `submit_price_unsigned` and nothing else.

```rust
/// By default unsigned transactions are disallowed, but implementing the validator
/// here we make sure that some particular calls (the ones produced by offchain worker)
/// are being whitelisted and marked as valid.
fn validate_unsigned(_source: TransactionSource, call: &Self::Call) -> TransactionValidity {
    // If `submit_price_unsigned` is being called, the transaction is valid.
    // Otherwise, it is an InvalidTransaction.
    if let Call::submit_price_unsigned { block_number, price: new_price } = call {
        let avg_price = Self::average_price()
        .map(|price| if &price > new_price { price - new_price } else { new_price - price })
        .unwrap_or(0);

        let valid_tx = | provide | {
            ValidTransaction::with_tag_prefix("ExampleOffchainWorker")
            .priority(T::UnsignedPriority::get().saturating_add(avg_price as _))
            .and_provides([&provide])
            .longevity(5)
            .propagate(true)
            .build()
        };
        valid_tx(b"submit_price_unsigned".to_vec())
    } else {
        InvalidTransaction::Call.into()
    }
}
```

However, notice that there is nothing preventing an attacker from sending malicious price data. Both `block_number` and `price` can be set to arbitrary values. For `block_number`, it would be valuable to ensure that it is not a block number in the future; only price data for the current block can be submitted. Additionally, medianization can be used to ensure that the reported price is not severely affected by outliers. Finally, unsigned submissions can be throttled by enforcing a delay after each submission.

Note that the simplest solution would be to sign the offchain submissions so that the runtime can validate that a known OCW is sending the price submission transactions.

# Mitigations

- Consider whether unsigned transactions is a requirement for the runtime that is being built. OCWs can also submit signed transactions or transactions with signed payloads.
- Ensure that each parameter provided to `validate_unsigned` is validated to prevent the runtime from entering a state that is vulnerable or undefined.

# References

- https://docs.substrate.io/main-docs/fundamentals/transaction-types/#unsigned-transactions
- https://docs.substrate.io/main-docs/fundamentals/offchain-operations/
- https://github.com/paritytech/substrate/blob/polkadot-v0.9.26/frame/examples/offchain-worker/src/lib.rs
- https://docs.substrate.io/tutorials/build-application-logic/add-offchain-workers/
- https://docs.substrate.io/reference/how-to-guides/offchain-workers/offchain-http-requests/
