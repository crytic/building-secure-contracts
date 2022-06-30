package keeper

import (
	"github.com/cosmos/cosmos-sdk/store/prefix"
	sdk "github.com/cosmos/cosmos-sdk/types"
	sdkerrors "github.com/cosmos/cosmos-sdk/types/errors"
	"github.com/trailofbits/incorrect_getsigners/x/incorrectgetsigners/types"
)

func (k Keeper) GetDelegation(ctx sdk.Context, delegator sdk.AccAddress) (sdk.AccAddress, error) {
	store := prefix.NewStore(ctx.KVStore(k.storeKey), []byte(types.DelegationKey))

	bz := store.Get(delegator.Bytes())
	if bz == nil {
		return delegator, nil
	}

	return bz, nil
}

func (k Keeper) SetDelegation(ctx sdk.Context, delegator, delegatee sdk.AccAddress) {
	store := prefix.NewStore(ctx.KVStore(k.storeKey), []byte(types.DelegationKey))
	store.Set(delegator.Bytes(), delegatee.Bytes())
}

func (k Keeper) ValidateDelegation(ctx sdk.Context, delegatee sdk.AccAddress, delegator sdk.AccAddress) error {
	x, err := k.GetDelegation(ctx, delegator)
	if err != nil {
		return err
	}
	if !x.Equals(delegatee) {
		return sdkerrors.Wrap(types.AuthError, delegatee.String())
	}

	return nil
}
