Some code snippets I will need for the README.md
```rust
	fn validate_transaction_parameters(
		_block_number: &T::BlockNumber,
		_new_price: &u32,
	) -> TransactionValidity {
		let valid_tx = | provide | {
			ValidTransaction::with_tag_prefix("ExampleOffchainWorker")
			.priority(UNSIGNED_TXS_PRIORITY)
			.and_provides([&provide])
			.longevity(5)
			.propagate(true)
			.build()
		};
		valid_tx(b"submit_price_unsigned".to_vec())
	}
```

```rust
    if let Call::submit_price_unsigned_with_signed_payload {
        price_payload: ref payload,
        ref signature,
    } = call
    {
        let signature_valid =
            SignedPayload::<T>::verify::<T::AuthorityId>(payload, signature.clone());
        if !signature_valid {
            return InvalidTransaction::BadProof.into()
        }
        Self::validate_transaction_parameters(&payload.block_number, &payload.price)
    } else if let Call::submit_price_unsigned { block_number, price: new_price } = call {
        Self::validate_transaction_parameters(block_number, new_price)
    } else {
        InvalidTransaction::Call.into()
    }
```