# Bad Randomness

To use randomness in a Substrate pallet, all you need to do is require a source of randomness in the `Config` trait of a pallet. This source of Randomness must implement the [`Randomness`](https://paritytech.github.io/substrate/master/frame_support/traits/trait.Randomness.html) trait. The trait provides two methods for obtaining randomness.

1. `random_seed`: This function takes no arguments and returns back a random value. Calling this value multiple times in a block will result in the same value.
2. `random`: Takes in a byte-array (a.k.a "context-identifier") and returns a value that is as independent as possible from other contexts.

Substrate provides the [Randomness Collective Flip Pallet](https://docs.rs/pallet-randomness-collective-flip/latest/pallet_randomness_collective_flip/) and a Verifiable Random Function implementation in the [BABE pallet](https://paritytech.github.io/substrate/master/pallet_babe/index.html). Developers can also choose to build their own source of randomness.

A bad source of randomness can lead to a variety of exploits such as the theft of funds or undefined system behavior.

# Example

The [`pallet-bad-lottery`](https://github.com/crytic/building-secure-contracts/blob/master/not-so-smart-contracts/substrate/randomness/pallet-bad-lottery.rs) pallet is a simplified "lottery" system that requires one to guess the next random number. If they guess correctly, they are the winner of the lottery.

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
    // Random value.
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

Note that the quality of randomness provided to the `pallet-bad-lottery` pallet is related to the randomness source. If the randomness source is the "Randomness Collective Flip Pallet", this lottery system is insecure. This is because the collective flip pallet implements "low-influence randomness". This makes it vulnerable to a collusion attack where a small minority of participants can give the same random number contribution making it highly likely to have the seed be this random number (click [here](https://ethresear.ch/t/rng-exploitability-analysis-assuming-pure-randao-based-main-chain/1825/7) to learn more). Additionally, as mentioned in the Substrate documentation, "low-influence randomness can be useful when defending against relatively weak adversaries. Using this pallet as a randomness source is advisable primarily in low-security situations like testing."

# Mitigations

- Use the randomness implementation provided by the [BABE pallet](https://paritytech.github.io/substrate/master/pallet_babe/index.html). This pallet provides "production-grade randomness, and is used in Polkadot. **Selecting this randomness source dictates that your blockchain use Babe consensus.**"
- Defer from creating a custom source of randomness unless specifically necessary for the runtime being developed.
- Do not use `random_seed` as the method of choice for randomness unless specifically necessary for the runtime being developed.

# References

- https://docs.substrate.io/main-docs/build/randomness/
- https://docs.substrate.io/reference/how-to-guides/pallet-design/incorporate-randomness/
- https://ethresear.ch/t/rng-exploitability-analysis-assuming-pure-randao-based-main-chain/1825/7
- https://ethresear.ch/t/collective-coin-flipping-csprng/3252/21
- https://github.com/paritytech/ink/issues/57#issuecomment-486998848
