#![cfg_attr(not(feature = "std"), no_std)]

pub use pallet::*;

#[frame_support::pallet]
pub mod pallet {
	use frame_support::{dispatch::DispatchResultWithPostInfo, pallet_prelude::{*, ValueQuery}};
	use frame_system::pallet_prelude::*;
	use sp_std::prelude::*;
	
	/// Pallet configuration
	#[pallet::config]
	pub trait Config: frame_system::Config {
		/// Because this pallet emits events, it depends on the runtime's definition of an event.
		type Event: From<Event<Self>> + IsType<<Self as frame_system::Config>::Event>;

		// Specifies the account that can perform some action
		type ForceOrigin: EnsureOrigin<Self::Origin>;
	}

	#[pallet::pallet]
	#[pallet::generate_store(pub(super) trait Store)]
	pub struct Pallet<T>(_);

	/// Storage item for important value that should be editable only by root
	#[pallet::storage]
	#[pallet::getter(fn get_important_val)]
	pub(super) type ImportantVal<T: Config> = StorageValue<_, u64, ValueQuery>;

	#[pallet::event]
	#[pallet::generate_deposit(pub(super) fn deposit_event)]
	pub enum Event<T: Config> {
		/// Emit when new important val is set.
		ImportantValSet(T::AccountId, u64),
	}

	#[pallet::hooks]
	impl<T: Config> Hooks<BlockNumberFor<T>> for Pallet<T> {}

	#[pallet::call]
	impl<T:Config> Pallet<T> {
		/// Set the important val
		/// Should be only callable by ForceOrigin
		#[pallet::weight(10_000)]
		pub fn set_important_val(
			origin: OriginFor<T>,
			new_val: u64
		) -> DispatchResultWithPostInfo {
			T::ForceOrigin::ensure_origin(origin.clone())?;
            let sender = ensure_signed(origin)?;
			// Change to new value
			<ImportantVal<T>>::put(new_val);

			// Emit event
			Self::deposit_event(Event::ImportantValSet(sender, new_val));

			Ok(().into())
		}
	}

}