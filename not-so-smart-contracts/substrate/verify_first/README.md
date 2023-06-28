# Verify First, Write Last

**NOTE**: As of [Polkadot v0.9.25](https://github.com/substrate-developer-hub/substrate-docs/issues/1215), the **Verify First, Write Last** practice is no longer required. However, since older versions are still vulnerable, and since it is still considered best practice, it is worth discussing the "Verify First, Write Last" idiom.

Substrate does not cache state prior to extrinsic dispatch; instead, it makes state changes as they are invoked. This contrasts with Ethereum transactions, where, if a transaction reverts, no state changes will persist. In the case of Substrate, if a state change is made and the dispatch then throws a `DispatchError`, the original state change will persist. This unique behavior has led to the adoption of the "Verify First, Write Last" practice.

```rust
{
  // Place all checks and throwing code here

  // ** No throwing code should be below this line **

  // Place all event emissions & storage writes here
}
```

# Example

In the [`pallet-verify-first`](https://github.com/crytic/building-secure-contracts/blob/master/not-so-smart-contracts/substrate/verify_first/pallet-verify-first.rs) pallet, the `init` dispatchable is used to set up the `TotalSupply` of the token and transfer it to the `sender`. `init` should be called only once. Therefore, the `Init` boolean is set to `true` when it is initially called. If `init` is called more than once, the transaction will generate an error because the `Init` value is already `true`.

```rust
/// Initialize the token
/// Transfers the total_supply amount to the caller
/// Throws an AlreadyInitialized error if init() has already been called
#[pallet::weight(10_000)]
pub fn init(
    origin: OriginFor<T>,
    supply: u64
) -> DispatchResultWithPostInfo {
    let sender = ensure_signed(origin)?;

    if supply > 0 {
        <TotalSupply<T>>::put(&supply);
    }

    // Set sender's balance to total_supply()
    <BalanceToAccount<T>>::insert(&sender, supply);

    // Revert previous changes if init() has already been called
    ensure!(!Self::is_init(), <Error<T>>::AlreadyInitialized);

    // Set Init StorageValue to `true`
    Init::<T>::put(true);

    // Emit event
    Self::deposit_event(Event::Initialized(sender));

    Ok(().into())
}
```

However, notice that the setting of `TotalSupply` and the transfer of funds occur before the check on `Init`. This violates the "Verify First, Write Last" practice. In an older version of Substrate, this would enable a malicious `sender` to call `init` multiple times and alter the values of `TotalSupply` and their token balance.

# Mitigations

- Adhere to the "Verify First, Write Last" practice by performing all necessary data validation before executing state changes and emitting events.

# References

- https://docs.substrate.io/main-docs/build/runtime-storage/#best-practices
