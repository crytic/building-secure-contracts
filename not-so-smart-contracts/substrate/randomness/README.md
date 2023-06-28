# Bad Randomness

To utilize randomness in a Substrate pallet, simply require a source of randomness in the `Config` trait of a pallet. This source of randomness must implement the [`Randomness`](https://paritytech.github.io/substrate/master/frame_support/traits/trait.Randomness.html) trait. The trait provides two methods for obtaining randomness:

1. `random_seed`: This function takes no arguments and returns a random value. Calling this function multiple times in a block results in the same value.
2. `random`: Takes in a byte array (a.k.a "context-identifier") and returns a value that is as independent as possible from other contexts.

Substrate offers the [Randomness Collective Flip Pallet](https://docs.rs/pallet-randomness-collective-flip/latest/pallet_randomness_collective_flip/) and a Verifiable Random Function implementation in the [BABE pallet](https://paritytech.github.io/substrate/master/pallet_babe/index.html). Developers can also opt to build their own source of randomness.

A poor source of randomness can lead to various exploits, such as theft of funds or unpredictable system behavior.

# Example

The [`pallet-bad-lottery`](https://github.com/crytic/building-secure-contracts/blob/master/not-so-smart-contracts/substrate/randomness/pallet-bad-lottery.rs) pallet is a simplified "lottery" system that requires one to guess the next random number. If a user guesses correctly, they are declared the winner of the lottery.

```rust
#[pallet::call]
impl<T:Config> Pallet<T> {
    /// Guess the random value
    /// If you guess correctly, you become the winner
    #[pallet::weight(10_000)]
    pub fn guess(
        origin: OriginFor<T>,
        guess: T::Hash
    ) -> DispatchResultWithPostInfo {
        let sender = ensure_signed(origin)?;
        // Random value
        let nonce = Self::get_and_increment_nonce();
        let (random_value, _) = T::MyRandomness::random(&nonce);
        // Check if guess is correct
        ensure!(guess == random_value, <Error<T>>::IncorrectGuess);
        <Winner<T>>::put(&sender);

        Self::deposit_event(Event::NewWinner(sender));

        Ok(().into())
    }
}

impl<T:Config> Pallet<T> {
    /// Increment the nonce each time guess() is called
    pub fn get_and_increment_nonce() -> Vec<u8> {
        let nonce = Nonce::<T>::get();
        Nonce::<T>::put(nonce.wrapping_add(1));
        nonce.encode()
    }
}
```

Note that the quality of randomness provided to the `pallet-bad-lottery` pallet depends on the randomness source. If the randomness source is the "Randomness Collective Flip Pallet", this lottery system is insecure. This is because the collective flip pallet implements "low-influence randomness", making it vulnerable to a collusion attack where a small minority of participants can provide the same random number contribution, making it highly likely that the seed will be this random number. (To learn more, click [here](https://ethresear.ch/t/rng-exploitability-analysis-assuming-pure-randao-based-main-chain/1825/7)). Additionally, as mentioned in the Substrate documentation, "low-influence randomness can be useful when defending against relatively weak adversaries. Using this pallet as a randomness source is advisable primarily in low-security situations like testing."

# Mitigations

- Use the randomness implementation provided by the [BABE pallet](https://paritytech.github.io/substrate/master/pallet_babe/index.html), which offers "production-grade randomness" and is used in Polkadot. **Selecting this randomness source mandates that your blockchain utilize Babe consensus.**
- Refrain from creating a custom source of randomness unless specifically necessary for the runtime being developed.
- Avoid using `random_seed` as the method of choice for randomness unless specifically necessary for the runtime being developed.

# References

- https://docs.substrate.io/main-docs/build/randomness/
- https://docs.substrate.io/reference/how-to-guides/pallet-design/incorporate-randomness/
- https://ethresear.ch/t/rng-exploitability-analysis-assuming-pure-randao-based-main-chain/1825/7
- https://ethresear.ch/t/collective-coin-flipping-csprng/3252/21
- https://github.com/paritytech/ink/issues/57#issuecomment-486998848
