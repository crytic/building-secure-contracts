# Origins

The origin of a call tells a dispatchable function where the call has come from. Origins are a way to implement access controls in the system.

There are three types of origins that can used in the runtime:

```rust
pub enum RawOrigin<AccountId> {
	Root,
	Signed(AccountId),
	None,
}
```

Outside of the out-of-box origins, custom origins can also be created that are catered to a specific runtime. The primary use case for custom origins is to configure privileged access to dispatch calls in the runtime, outside of `RawOrigin::Root`.

Using privileged origins, like `RawOrigin::Root` or custom origins, can lead to access control violations if not used correctly. It is a common error to use `ensure_signed` in place of `ensure_root` which would allow any user to bypass the access control placed by using `ensure_root`.

# Example

In the [`pallet-bad-origin`](https://github.com/crytic/building-secure-contracts/blob/master/not-so-smart-contracts/substrate/origins/pallet-bad-origin.rs) pallet, there is a `set_important_val` function that should be only callable by the `ForceOrigin` _custom_ origin type. This custom origin allows the pallet to specify that only a specific account can call `set_important_val`.

```rust
#[pallet::call]
impl<T:Config> Pallet<T> {
    /// Set the important val
    /// Should be only callable by ForceOrigin
    #[pallet::weight(10_000)]
    pub fn set_important_val(
        origin: OriginFor<T>,
        new_val: u64
    ) -> DispatchResultWithPostInfo {
        let sender = ensure_signed(origin)?;
        // Change to new value
        <ImportantVal<T>>::put(new_val);

        // Emit event
        Self::deposit_event(Event::ImportantValSet(sender, new_val));

        Ok(().into())
    }
}
```

However, the `set_important_val` is using `ensure_signed`; this allows any account to set `ImportantVal`. To allow only the `ForceOrigin` to call `set_important_val` the following change can be made:

```rust
T::ForceOrigin::ensure_origin(origin.clone())?;
let sender = ensure_signed(origin)?;
```

# Mitigations

- Ensure that the correct access controls are placed on privileged functions.
- Develop user documentation on all risks associated with the system, including those associated with privileged users.
- A thorough suite of unit tests that validates access controls is crucial.

# References

- https://docs.substrate.io/main-docs/build/origins/
- https://docs.substrate.io/tutorials/build-application-logic/specify-the-origin-for-a-call/
- https://paritytech.github.io/substrate/master/pallet_sudo/index.html#
- https://paritytech.github.io/substrate/master/pallet_democracy/index.html
