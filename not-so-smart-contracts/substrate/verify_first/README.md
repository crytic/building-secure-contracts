# Verify First, Write Last

**NOTE**: As of [Polkadot v0.9.25](https://github.com/substrate-developer-hub/substrate-docs/issues/1215), the **Verify First, Write Last** practice is no longer required. However, since older versions are still vulnerable and because it is still best practice, it is worth discussing the "Verify First, Write Last" idiom.

Substrate does not cache state prior to extrinsic dispatch. Instead, state changes are made as they are invoked. This is in contrast to a transaction in Ethereum where, if the transaction reverts, no state changes will persist. In the case of Substrate, if a state change is made and then the dispatch throws a `DispatchError`, the original state change will persist. This unique behavior has led to the "Verify First, Write Last" practice.

```rust
{
  // all checks and throwing code go here

  // ** no throwing code below this line **

  // all event emissions & storage writes go here
}
```

# Example

In the [`pallet-verify-first`](https://github.com/crytic/building-secure-contracts/blob/master/not-so-smart-contracts/substrate/verify_first/pallet-verify-first.rs) pallet, the `init` dispatchable is used to set up the `TotalSupply` of the token and transfer them to the `sender`. `init` should be only called once. Thus, the `Init` boolean is set to `true` when it is called initially. If `init` is called more than once, the transaction will throw an error because `Init` is already `true`.

```rust
/// Initialize the token
/// Transfers the total_supply amount to the caller
/// If init() has already been called, throw AlreadyInitialized error
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

    // Revert above changes if init() has already been called
    ensure!(!Self::is_init(), <Error<T>>::AlreadyInitialized);

    // Set Init StorageValue to `true`
    Init::<T>::put(true);

    // Emit event
    Self::deposit_event(Event::Initialized(sender));

    Ok(().into())
}
```

However, notice that the setting of `TotalSupply` and the transfer of funds happens before the check on `Init`. This violates the "Verify First, Write Last" practice. In an older version of Substrate, this would allow a malicious `sender` to call `init` multiple times and change the value of `TotalSupply` and their balance of the token.

# Mitigations

- Follow the "Verify First, Write Last" practice by doing all the necessary data validation before performing state changes and emitting events.

# References

- https://docs.substrate.io/main-docs/build/runtime-storage/#best-practices
