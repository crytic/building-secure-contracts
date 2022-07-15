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
    let updated_from_balance = sender_balance.sub(value);
    let updated_to_balance = receiver_balance.add(value);

    // Update state
    <Balances<T>>::insert(&sender, updated_from_balance);
    <Balances<T>>::insert(&to, updated_to_balance);

    // Emit event
    Self::deposit_event(RawEvent::Transfer(sender, to, value));
    Ok(())
}