# Unsigned Transaction Validation

Substrate runtime supports three types of transactions: signed, unsigned, and inherent. Unsigned transactions do not require a signature and do not include information about the sender. This makes them vulnerable to spam, replay attacks, and other malicious actions. To mitigate these risks, Substrate enables users to create custom functions to validate unsigned transactions. Correctly validating unsigned transactions is crucial, as failure in this area could allow malicious actors to spoof data and cause unexpected behavior or replay attacks.

Unsigned transaction validation must be provided by the pallet that decides to accept them. To do this, a pallet must implement the [`frame_support::unsigned::ValidateUnsigned`](https://paritytech.github.io/substrate/master/frame_support/attr.pallet.html#validate-unsigned-palletvalidate_unsigned-optional) trait. The `validate_unsigned` function, which must be implemented as part of this trait, provides the necessary logic to ensure that the transaction is valid. Pallets can also incorporate an off-chain worker (OCW) using the `offchain_worker` [hook](https://paritytech.github.io/substrate/master/frame_support/attr.pallet.html#hooks-pallethooks-optional), which can send unsigned transactions by calling [`SubmitTransaction::submit_unsigned_transaction`](https://paritytech.github.io/substrate/master/frame_system/offchain/struct.SubmitTransaction.html). The `validate_unsigned` function then validates the transaction before passing it to the final dispatchable function.

# Example

The [`pallet-bad-unsigned`](https://github.com/crytic/building-secure-contracts/blob/master/not-so-smart-contracts/substrate/validate_unsigned/pallet-bad-unsigned.rs) pallet demonstrates improper unsigned transaction validation. This example pallet tracks the average rolling price of an asset fetched by an OCW. The `fetch_price` function, which the OCW calls, naively returns a fixed price of 100 (note that a real-world implementation would use an [HTTP request](https://github.com/paritytech/substrate/blob/e8a7d161f39db70cb27fdad6c6e215cf493ebc3b/frame/examples/offchain-worker/src/lib.rs#L572-L625) to fetch actual price data). The `validate_unsigned` function simply validates that the `Call` is made to `submit_price_unsigned` without verifying the submitted data.

```rust
/// By default, unsigned transactions are disallowed, but implementing the validator.
/// Here, we make sure that only specific calls (those made by the off-chain worker)
/// are whitelisted and considered valid.
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

In this example, nothing prevents an attacker from submitting malicious price data with arbitrary `block_number` and `price` values. To improve the validation process, only current block numbers should be allowed, with proper data ranges and limitations in place. Also, consider medianization or throttling submission rates to minimize the impact of malicious data. Nonetheless, the most straightforward solution would involve signing off-chain submissions, allowing the runtime to verify the authenticity of OCW transactions.

# Mitigations

- Evaluate whether unsigned transactions are necessary for the runtime under development. Alternatives include using signed transactions or transactions with signed payloads for OCWs.
- Thoroughly validate each parameter provided to the `validate_unsigned` function, ensuring that the runtime remains secure and well-defined at all times.

# References

- https://docs.substrate.io/main-docs/fundamentals/transaction-types/#unsigned-transactions
- https://docs.substrate.io/main-docs/fundamentals/offchain-operations/
- https://github.com/paritytech/substrate/blob/polkadot-v0.9.26/frame/examples/offchain-worker/src/lib.rs
- https://docs.substrate.io/tutorials/build-application-logic/add-offchain-workers/
- https://docs.substrate.io/reference/how-to-guides/offchain-workers/offchain-http-requests/
