# Don't Panic!

Panics occur when a node enters a state it cannot handle, which causes the program or process to stop instead of attempting to proceed. Various factors can lead to panics, such as out-of-bounds array access, improper data validation, type conversions, and many others. A well-designed Substrate node must NEVER panic! If a node panics, it becomes vulnerable to denial-of-service (DoS) attacks.

# Example

In the [`pallet-dont-panic`](https://github.com/crytic/building-secure-contracts/blob/master/not-so-smart-contracts/substrate/dont_panic/pallet-dont-panic.rs) pallet, the `find_important_value` dispatchable checks if `useful_amounts[0]` is greater than `1_000`. If it is, the `ImportantVal` `StorageValue` is set to the value contained in `useful_amounts[0]`.

```rust
    /// Do some work
    ///
    /// Parameters:
    /// - `useful_amounts`: A vector of u64 values which contains an important value.
    ///
    /// Emits `FoundVal` event when successful.
    #[pallet::weight(10_000)]
    pub fn find_important_value(
        origin: OriginFor<T>,
        useful_amounts: Vec<u64>,
    ) -> DispatchResultWithPostInfo {
        let sender = ensure_signed(origin)?;

        ensure!(useful_amounts[0] > 1_000, <Error<T>>::NoImportantValueFound);

        // Found the important value
        ImportantValue::<T>::put(&useful_amounts[0]);
        [...]
    }
```

However, note that there is no check before the array indexing to verify whether the length of `useful_amounts` is greater than zero. Consequently, if `useful_amounts` is empty, the indexing will trigger an array out-of-bounds error, causing the node to panic. Since the `find_important_value` function can be called by anyone, an attacker could set `useful_amounts` to an empty array and spam the network with malicious transactions, launching a DoS attack.

# Mitigations

- Write non-throwing Rust code (e.g., prefer returning [`Result`](https://paritytech.github.io/substrate/master/frame_support/dispatch/result/enum.Result.html) types, use [`ensure!`](https://paritytech.github.io/substrate/master/frame_support/macro.ensure.html), etc.).
- Thoroughly validate all input parameters to avoid unexpected panics.
- Implement a comprehensive suite of unit tests.
- Perform fuzz testing (e.g., using [`test-fuzz`](https://github.com/trailofbits/test-fuzz)) to explore a wider range of inputs.

# References

- https://docs.substrate.io/main-docs/build/events-errors/#errors
