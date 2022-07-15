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

pub(super) fn transfer(
    origin: OriginFor<T>,
    to: T::AccountId,
    #[pallet::compact] amount: T::Balance,
) -> DispatchResultWithPostInfo {
    let sender = ensure_signed(origin)?;
    // Current balances
    let sender_balance = Self::get_balance(&sender);
    let receiver_balance = Self::get_balance(&to);
    
    // Calculate new balances.
    let updated_from_balance = sender_balance.checked_sub(value).ok_or(<Error<T>>::InsufficientFunds)?;
    let updated_to_balance = receiver_balance.checked_add(value).expect("Entire supply fits in u64, qed");

    // Update state
    <Balances<T>>::insert(&sender, updated_from_balance);
    <Balances<T>>::insert(&to, updated_to_balance);

    // Emit event
    Self::deposit_event(RawEvent::Transfer(sender, to, value));
    Ok(())
}