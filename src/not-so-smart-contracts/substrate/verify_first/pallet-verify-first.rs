#![cfg_attr(not(feature = "std"), no_std)]

pub use pallet::*;

#[frame_support::pallet]
pub mod pallet {
	use frame_support::{dispatch::DispatchResultWithPostInfo, pallet_prelude::*};
	use frame_system::pallet_prelude::*;

	/// Pallet configuration
	#[pallet::config]
	pub trait Config: frame_system::Config {
		/// Because this pallet emits events, it depends on the runtime's definition of an event.
		type Event: From<Event<Self>> + IsType<<Self as frame_system::Config>::Event>;
	}

	#[pallet::pallet]
	#[pallet::generate_store(pub(super) trait Store)]
	pub struct Pallet<T>(_);

	// DEFAULT Total supply of tokens
	#[pallet::type_value]
	pub(super) fn TotalSupplyDefaultValue<T: Config>() -> u64 {
		1000
	}

	// Data structure that holds the total supply of tokens
	#[pallet::storage]
	#[pallet::getter(fn total_supply)]
	pub(super) type TotalSupply<T: Config> =
		StorageValue<_, u64, ValueQuery, TotalSupplyDefaultValue<T>>;

	// Data structure that holds whether or not the pallet's init() function has been called
	#[pallet::storage]
	#[pallet::getter(fn is_init)]
	pub(super) type Init<T: Config> = StorageValue<_, bool, ValueQuery>;

	/// Storage item for balances to accounts mapping.
	#[pallet::storage]
	#[pallet::getter(fn get_balance)]
	pub(super) type BalanceToAccount<T: Config> = StorageMap<
		_, 
		Blake2_128Concat, 
		T::AccountId, 
		u64,
		ValueQuery
		>;

	/// Token mint can emit two Event types.
	#[pallet::event]
	#[pallet::generate_deposit(pub(super) fn deposit_event)]
	pub enum Event<T: Config> {
		/// Token was initialized by user
		Initialized(T::AccountId),
		/// Tokens were successfully transferred between accounts. [from, to, value]
		Transferred(T::AccountId, T::AccountId, u64),
	}

	#[pallet::hooks]
	impl<T: Config> Hooks<BlockNumberFor<T>> for Pallet<T> {}

	#[pallet::error]
	pub enum Error<T> {
		/// Attempted to initialize the token after it had already been initialized.
		AlreadyInitialized,
		/// Attempted to transfer more funds than were available
		InsufficientFunds,
	}
	
	#[pallet::call]
	impl<T:Config> Pallet<T> {
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
			let update_sender = sender_balance.checked_sub(amount).ok_or(<Error<T>>::InsufficientFunds)?;
			let update_to = receiver_balance.checked_add(amount).expect("Entire supply should fit in u64");

			// Update both accounts storage.
			<BalanceToAccount<T>>::insert(&sender, update_sender);
			<BalanceToAccount<T>>::insert(&to, update_to);

			// Emit event.
			Self::deposit_event(Event::Transferred(sender, to, amount));
			Ok(().into())
		}
	}
}