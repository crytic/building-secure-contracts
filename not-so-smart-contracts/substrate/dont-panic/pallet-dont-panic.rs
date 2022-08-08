#![cfg_attr(not(feature = "std"), no_std)]

pub use pallet::*;

#[frame_support::pallet]
pub mod pallet {
	use frame_support::{dispatch::DispatchResultWithPostInfo, pallet_prelude::*, weights::*};
	use frame_system::pallet_prelude::*;
	use sp_std::prelude::*;

	/// Pallet configuration
	#[pallet::config]
	pub trait Config: frame_system::Config {
		/// Because this pallet emits events, it depends on the runtime's definition of an event.
		type Event: From<Event<Self>> + IsType<<Self as frame_system::Config>::Event>;
	}

	#[pallet::pallet]
	#[pallet::without_storage_info]
	#[pallet::generate_store(pub(super) trait Store)]
	pub struct Pallet<T>(_);

	/// Storage item for useful_amounts passed to the do_work function
	#[pallet::storage]
	#[pallet::getter(fn get_val)]
	pub(super) type ImportantValue<T: Config> = StorageValue<_, u64, ValueQuery>;

	#[pallet::event]
	#[pallet::generate_deposit(pub(super) fn deposit_event)]
	pub enum Event<T: Config> {
		/// Emit after do_work successfully completes
		FoundVal(T::AccountId, u64),
	}

	#[pallet::hooks]
	impl<T: Config> Hooks<BlockNumberFor<T>> for Pallet<T> {}

	#[pallet::call]
	impl<T:Config> Pallet<T> {
		/// Do some work
		///
		/// Parameters:
		/// - `useful_amount`: A vector of u64 values that we want to store.
		///
		/// Emits `DidWork` event when successful.
		#[pallet::weight(10_000)]
		pub fn do_work(
			origin: OriginFor<T>,
			useful_amounts: Vec<u64>,
		) -> DispatchResultWithPostInfo {
			let sender = ensure_signed(origin)?;
			if useful_amounts[0] > 0 {
				ImportantValue::<T>::put(&useful_amounts[0]);
			}			
			// Emit event
			Self::deposit_event(Event::FoundVal(sender, useful_amounts[0]));
			Ok(().into())
		}
	}
}