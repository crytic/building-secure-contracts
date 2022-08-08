#![cfg_attr(not(feature = "std"), no_std)]

pub use pallet::*;

#[frame_support::pallet]
pub mod pallet {
	use frame_support::{dispatch::DispatchResultWithPostInfo, pallet_prelude::{*, ValueQuery}};
	use frame_system::pallet_prelude::*;
	use frame_support::traits::Randomness;
	use sp_std::prelude::*;
	
	/// Pallet configuration
	#[pallet::config]
	pub trait Config: frame_system::Config {
		/// Because this pallet emits events, it depends on the runtime's definition of an event.
		type Event: From<Event<Self>> + IsType<<Self as frame_system::Config>::Event>;
		/// Create a randomness type for this pallet
		type MyRandomness: Randomness<Self::Hash, Self::BlockNumber>;
	}

	#[pallet::pallet]
	#[pallet::generate_store(pub(super) trait Store)]
	pub struct Pallet<T>(_);

	/// Storage item for nonce
	#[pallet::storage]
	#[pallet::getter(fn get_nonce)]
	pub(super) type Nonce<T: Config> = StorageValue<_, u64, ValueQuery>;

	/// Storage item for current winner
	#[pallet::storage]
	#[pallet::getter(fn get_winner)]
	pub(super) type Winner<T: Config> = StorageValue<_, T::AccountId, OptionQuery>;

	#[pallet::event]
	#[pallet::generate_deposit(pub(super) fn deposit_event)]
	pub enum Event<T: Config> {
		/// Emit when new winner is found
		NewWinner(T::AccountId),
	}

	#[pallet::hooks]
	impl<T: Config> Hooks<BlockNumberFor<T>> for Pallet<T> {}

	#[pallet::error]
	pub enum Error<T> {
		/// Guessed the wrong number.
		IncorrectGuess,
	}

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
}