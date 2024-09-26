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
	#[pallet::getter(fn useful_amounts)]
	pub(super) type UsefulAmounts<T: Config> = StorageValue<_, Vec<u64>, ValueQuery>;

	#[pallet::event]
	#[pallet::generate_deposit(pub(super) fn deposit_event)]
	pub enum Event<T: Config> {
		/// Emit after do_work successfully completes
		DidWork(T::AccountId),
	}

	#[pallet::hooks]
	impl<T: Config> Hooks<BlockNumberFor<T>> for Pallet<T> {}

	/// Custom weight function implementation 
	pub struct MyWeightFunction(u64);

	/// The weight is linearly proportional to the length of the amounts array
	impl WeighData<(&Vec<u64>,)> for MyWeightFunction {
		fn weigh_data(&self, (amounts,): (&Vec<u64>,)) -> Weight {
			self.0.saturating_mul(amounts.len() as u64).into()
		}
	}
	
	/// Custom weight function implementations need to implement the PaysFee trait
	impl<T> PaysFee<T> for MyWeightFunction {
		fn pays_fee(&self, _: T) -> Pays {
			Pays::Yes
		}
	}
	
	/// Custom weight function implementations need to implement the ClassifyDispatch trait
	impl<T> ClassifyDispatch<T> for MyWeightFunction {
		fn classify_dispatch(&self, _: T) -> DispatchClass {
			// Classify all calls as Normal (which is the default)
			Default::default()
		}
	}

	#[pallet::call]
	impl<T:Config> Pallet<T> {
		/// Do some work
		///
		/// Parameters:
		/// - `useful_amount`: A vector of u64 values that we want to store.
		///
		/// Emits `DidWork` event when successful.
		#[pallet::weight(MyWeightFunction(10_000_000))]
		pub fn do_work(
			origin: OriginFor<T>,
			useful_amounts: Vec<u64>,
		) -> DispatchResultWithPostInfo {
			let sender = ensure_signed(origin)?;
			UsefulAmounts::<T>::put(useful_amounts);
			// Do other important constant-time (O(1)) work 
			
			// Emit event
			Self::deposit_event(Event::DidWork(sender));
			Ok(().into())
		}
	}
}