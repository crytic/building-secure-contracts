pub enum Event<T: Config> {
    MintedNewSupply(T::AccountId),
    Transfered(T::AccountId, T::AccountId, T::Balance),
}

#[pallet::storage]
#[pallet::getter(fn get_balance)]
pub(super) type BalanceToAccount<T: Config> = StorageMap <
    _,
    Blake2_128Concat,
    T::AccountId,
    T::Balance,
    ValueQuery
>;

#[pallet::weight(10_000 + T::DbWeight::get().writes(1))]
pub(super) fn mint(
    origin: OriginFor<T>,
    #[pallet::compact] amount: T::Balance
) -> DispatchResultWithPostInfo {

    let sender = ensure_signed(origin)?;

    // Update storage
    <BalanceToAccount<T>>::insert(&sender, amount);
    
    // Check if the kitty does not already exist in storage
    ensure!(Self::kitties(&kitty_id) == None, <Error<T>>::KittyExists);

    // Emit an event
    Self::deposit_event(Event::MintedNewSupply(sender));

    // Return successful DispatchResultWithPostInfo
    Ok(().into())
}