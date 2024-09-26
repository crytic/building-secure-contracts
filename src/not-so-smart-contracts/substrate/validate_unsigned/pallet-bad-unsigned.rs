/// Source: https://github.com/paritytech/substrate/blob/e8a7d161f39db70cb27fdad6c6e215cf493ebc3b/frame/examples/offchain-worker/src/lib.rs
/// This example was re-purposed from the above source
#![cfg_attr(not(feature = "std"), no_std)]

use frame_support::traits::Get;
use frame_system::{
	self as system,
	offchain::{SubmitTransaction, SendTransactionTypes},
};
use sp_runtime::{
	transaction_validity::{InvalidTransaction, TransactionValidity, ValidTransaction},
};

pub use pallet::*;

#[frame_support::pallet]
pub mod pallet {
	use super::*;
	use frame_support::pallet_prelude::*;
	use frame_system::pallet_prelude::*;

	/// This pallet's configuration trait
	#[pallet::config]
	pub trait Config: SendTransactionTypes<Call<Self>> + frame_system::Config {

		/// The overarching event type.
		type Event: From<Event<Self>> + IsType<<Self as frame_system::Config>::Event>;

		/// The overarching dispatch call type.
		type Call: From<Call<Self>>;

		/// Maximum number of prices.
		#[pallet::constant]
		type MaxPrices: Get<u32>;

		/// A configuration for base priority of unsigned transactions.
		///
		/// This is exposed so that it can be tuned for particular runtime, when
		/// multiple pallets send unsigned transactions.
		#[pallet::constant]
		type UnsignedPriority: Get<TransactionPriority>;
	}

	#[pallet::pallet]
	#[pallet::generate_store(pub(super) trait Store)]
	pub struct Pallet<T>(_);

	/// A vector of recently submitted prices.
	/// This is used to calculate average price, should have bounded size.
	#[pallet::storage]
	#[pallet::getter(fn prices)]
	pub(super) type Prices<T: Config> = StorageValue<_, BoundedVec<u32, T::MaxPrices>, ValueQuery>;
	
	/// Events for the pallet.
	#[pallet::event]
	#[pallet::generate_deposit(pub(super) fn deposit_event)]
	pub enum Event<T: Config> {
		/// Event generated when new price is accepted to contribute to the list of prices.
		NewPrice { price: u32, block_number: T::BlockNumber, maybe_who: Option<T::AccountId> },
	}

	#[pallet::hooks]
	impl<T: Config> Hooks<BlockNumberFor<T>> for Pallet<T> {
		/// Offchain Worker entry point.
		/// By implementing `fn offchain_worker` you declare a new offchain worker.
		fn offchain_worker(block_number: T::BlockNumber) {
			log::info!("Hello I'm an offchain worker!");
			
			// Print debug information
			let parent_hash = <system::Pallet<T>>::block_hash(block_number - 1u32.into());
			log::debug!("Current block: {:?} (parent hash: {:?}", block_number, parent_hash);

			// Get and log average price
			let average: Option<u32> = Self::average_price();
			log::debug!("Current price: {:?}", average);

			// Send unsigned transaction to log latest price from an offchain resource
			let res = Self::fetch_price_and_send_raw_unsigned(block_number);
			if let Err(e) = res {
				// Throw error
				log::error!("Error: {}", e);
			}
		}
	}

	/// A public part of the pallet.
	#[pallet::call]
	impl<T: Config> Pallet<T> {
		/// Submit new price to the list via unsigned transaction.
		/// 
		/// It's important to specify `weight` for unsigned calls as well, because even though
		/// they don't charge fees, we still don't want a single block to contain unlimited
		/// number of such transactions.
		#[pallet::weight(0)]
		pub fn submit_price_unsigned(
			origin: OriginFor<T>,
			_block_number: T::BlockNumber,
			price: u32,
		) -> DispatchResultWithPostInfo {
			// This ensures that the function can only be called via unsigned transaction.
			ensure_none(origin)?;
			// Add the price to the on-chain list, but mark it as coming from an empty address.
			Self::add_price(None, price, _block_number);
			Ok(().into())
		}

	}
	
	/// Validate unsigned call to this module.
	#[pallet::validate_unsigned]
	impl<T: Config> ValidateUnsigned for Pallet<T> {
		type Call = Call<T>;

		/// By default unsigned transactions are disallowed, but implementing the validator
		/// here we make sure that some particular calls (the ones produced by offchain worker)
		/// are being whitelisted and marked as valid.
		fn validate_unsigned(_source: TransactionSource, call: &Self::Call) -> TransactionValidity {
			// If `submit_price_unsigned` is being called, the transaction is valid.
			// Otherwise, it is an InvalidTransaction.
			if let Call::submit_price_unsigned { block_number, price: new_price } = call {
				let avg_price = Self::average_price()
				.map(|price| if &price > new_price { price - new_price } else { new_price - price })
				.unwrap_or(0);

				let valid_tx = | provide | {
					ValidTransaction::with_tag_prefix("ExampleOffchainWorker")
					.priority(T::UnsignedPriority::get().saturating_add(avg_price as _))
					.and_provides([&provide])
					.longevity(5)
					.propagate(true)
					.build()
				};
				valid_tx(b"submit_price_unsigned".to_vec())
			} else {
				InvalidTransaction::Call.into()
			}
		}
	}
}

// Helper functions of the pallet
impl<T: Config> Pallet<T> {

	/// A helper function to fetch the price and send a raw unsigned transaction.
	fn fetch_price_and_send_raw_unsigned(block_number: T::BlockNumber) -> Result<(), &'static str> {
		// Make an external "HTTP request" to fetch the current price.
		// Note this call will block until response is received.
		let price = Self::fetch_price();

		// Create wrapped `Call` struct that will end up calling `submit_price_unsigned` 
		let call = Call::submit_price_unsigned { block_number, price };

		// Submit the unsigned transaction on-chain
		SubmitTransaction::<T, Call<T>>::submit_unsigned_transaction(call.into())
			.map_err(|()| "Unable to submit unsigned transaction.")?;

		Ok(())
	}


	/// Naively "fetch" current price and return the result.
	fn fetch_price() -> u32 {
		1000
	}

	/// Calculate current average price.
	fn average_price() -> Option<u32> {
		let prices = <Prices<T>>::get();
		if prices.is_empty() {
			None
		} else {
			Some(prices.iter().fold(0_u32, |a, b| a.saturating_add(*b)) / prices.len() as u32)
		}
	}

	/// Add new price to the list.
	fn add_price(maybe_who: Option<T::AccountId>, price: u32, block_number: T::BlockNumber) {
		<Prices<T>>::mutate(|prices| {
			if prices.try_push(price).is_err() {
				prices[(price % T::MaxPrices::get()) as usize] = price;
			}
		});
		// Here we are raising the NewPrice event
		Self::deposit_event(Event::NewPrice { price, block_number, maybe_who });
	}
}