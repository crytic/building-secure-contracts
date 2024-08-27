# Don't Panic!

Panics occur when the node enters a state that it cannot handle and stops the program / process instead of trying to proceed. Panics can occur for a large variety of reasons such as out-of-bounds array access, incorrect data validation, type conversions, and much more. A well-designed Substrate node must NEVER panic! If a node panics, it opens up the possibility for a denial-of-service (DoS) attack.

# Example

In the [`pallet-dont-panic`](https://github.com/crytic/building-secure-contracts/blob/master/not-so-smart-contracts/substrate/dont_panic/pallet-dont-panic.rs) pallet, the `find_important_value` dispatchable checks to see if `useful_amounts[0]` is greater than `1_000`. If so, it sets the `ImportantVal` `StorageValue` to the value held in `useful_amounts[0]`.

```rust
    /// Do some work
    ///
    /// Parameters:
    /// - `useful_amounts`: A vector of u64 values in which there is a important value.
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

However, notice that there is no check before the array indexing to see whether the length of `useful_amounts` is greater than zero. Thus, if `useful_amounts` is empty, the indexing will cause an array out-of-bounds error which will make the node panic. Since the `find_important_value` function is callable by anyone, an attacker can set `useful_amounts` to an empty array and spam the network with malicious transactions to launch a DoS attack.

# Mitigations

- Write non-throwing Rust code (e.g. prefer returning [`Result`](https://paritytech.github.io/substrate/master/frame_support/dispatch/result/enum.Result.html) types, use [`ensure!`](https://paritytech.github.io/substrate/master/frame_support/macro.ensure.html), etc.).
- Proper data validation of all input parameters is crucial to ensure that an unexpected panic does not occur.
- A thorough suite of unit tests should be implemented.
- Fuzz testing (e.g. using [`test-fuzz`](https://github.com/trailofbits/test-fuzz)) can aid in exploring more of the input space.

# References

- https://docs.substrate.io/main-docs/build/events-errors/#errors
