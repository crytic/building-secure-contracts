#![cfg_attr(not(feature = "std"), no_std)]

pub use pallet::*;

#[frame_support::pallet]
pub mod pallet {
	use frame_support::{dispatch::DispatchResultWithPostInfo, pallet_prelude::*};
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

	/// Storage item for holding an ImportantValue
	#[pallet::storage]
	#[pallet::getter(fn get_val)]
	pub(super) type ImportantValue<T: Config> = StorageValue<_, u64, ValueQuery>;

	#[pallet::event]
	#[pallet::generate_deposit(pub(super) fn deposit_event)]
	pub enum Event<T: Config> {
		/// Emit after val is found
		FoundVal(T::AccountId, u64),
	}

	#[pallet::hooks]
	impl<T: Config> Hooks<BlockNumberFor<T>> for Pallet<T> {}

    #[pallet::error]
	pub enum Error<T> {
		NoImportantValueFound,
	}

	#[pallet::call]
	impl<T:Config> Pallet<T> {
		/// Find important value
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
						
			// Emit event
			Self::deposit_event(Event::FoundVal(sender, useful_amounts[0]));
			Ok(().into())
		}
	}
}