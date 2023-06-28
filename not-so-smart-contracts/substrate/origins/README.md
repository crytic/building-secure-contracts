# Origins

In the context of dispatchable functions, the origin of a call indicates where the call has come from. Origins serve as a means to implement access controls in a system.

There are three types of origins that can be used in the runtime:

```rust
pub enum RawOrigin<AccountId> {
	Root,
	Signed(AccountId),
	None,
}
```

Aside from the default origins, custom origins tailored for specific runtimes can also be created. The primary purpose of custom origins is to configure privileged access for dispatch calls in the runtime, outside of `RawOrigin::Root`.

Using privileged origins, such as `RawOrigin::Root` or custom origins, can result in access control violations if not employed properly. A common mistake is using `ensure_signed` instead of `ensure_root`, which allows any user to bypass the access control imposed by `ensure_root`.

# Example

The [`pallet-bad-origin`](https://github.com/crytic/building-secure-contracts/blob/master/not-so-smart-contracts/substrate/origins/pallet-bad-origin.rs) pallet features a `set_important_val` function that should be callable only by the `ForceOrigin` _custom_ origin type. This custom origin enables the pallet to specify that only a specific account can call `set_important_val`.

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

However, since `set_important_val` is using `ensure_signed`, any account can set `ImportantVal`. To restrict `set_important_val` to `ForceOrigin` calls only, the following change can be made:

```rust
T::ForceOrigin::ensure_origin(origin.clone())?;
let sender = ensure_signed(origin)?;
```

# Mitigations

- Ensure that appropriate access controls are applied to privileged functions.
- Create user documentation that covers all risks associated with the system, including those related to privileged users.
- Develop a comprehensive suite of unit tests to verify access controls.

# References

- https://docs.substrate.io/main-docs/build/origins/
- https://docs.substrate.io/tutorials/build-application-logic/specify-the-origin-for-a-call/
- https://paritytech.github.io/substrate/master/pallet_sudo/index.html#
- https://paritytech.github.io/substrate/master/pallet_democracy/index.html
