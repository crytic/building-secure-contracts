# Arithmetic overflow

Arithmetic overflow in Substrate occurs when arithmetic operations are performed using primitive operations instead of specialized functions that check for overflow. When a Substrate node is compiled in `debug` mode, integer overflows will cause the program to panic. However, when the node is compiled in `release` mode (e.g. `cargo build --release`), Substrate will perform two's complement wrapping. A production-ready node will be compiled in `release` mode, which makes it vulnerable to arithmetic overflow.

# Example

In the [`pallet-overflow`](https://github.com/crytic/building-secure-contracts/blob/master/not-so-smart-contracts/substrate/arithmetic_overflow/pallet-overflow.rs) pallet, notice that the `transfer` function sets `update_sender` and `update_to` using primitive arithmetic operations.

```rust
   /// Allow minting account to transfer a given balance to another account.
   ///
   /// Parameters:
   /// - `to`: The account to receive the transfer.
   /// - `amount`: The amount of balance to transfer.
   ///
   /// Emits `Transferred` event when successful.
   #[pallet::weight(10_000)]
   pub fn transfer(
       origin: OriginFor<T>,
       to: T::AccountId,
       amount: u64,
   ) -> DispatchResultWithPostInfo {
       let sender = ensure_signed(origin)?;
       let sender_balance = Self::get_balance(&sender);
       let receiver_balance = Self::get_balance(&to);

       // Calculate new balances.
       let update_sender = sender_balance - amount;
       let update_to = receiver_balance + amount;
       [...]
   }
```

The sender of the extrinsic can exploit this vulnerability by causing `update_sender` to underflow, which artificially inflates their balance.

**Note**: Aside from the stronger mitigations mentioned below, a check to make sure that `sender` has at least `amount` balance would have also prevented an underflow.

# Mitigations

- Use `checked` or `saturating` functions for arithmetic operations.
  - [`CheckedAdd` trait](https://docs.rs/num/0.4.0/num/traits/trait.CheckedAdd.html)
  - [`Saturating` trait](https://docs.rs/num/0.4.0/num/traits/trait.Saturating.html)

# References

- https://doc.rust-lang.org/book/ch03-02-data-types.html#integer-overflow
- https://docs.substrate.io/reference/how-to-guides/basics/use-helper-functions/
