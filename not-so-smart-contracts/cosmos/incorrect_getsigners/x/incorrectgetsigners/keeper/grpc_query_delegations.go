package keeper

import (
	"context"
	sdk "github.com/cosmos/cosmos-sdk/types"
	"github.com/trailofbits/incorrect_getsigners/x/incorrectgetsigners/types"
	"google.golang.org/grpc/codes"
	"google.golang.org/grpc/status"
)

func (k Keeper) Delegations(goCtx context.Context, req *types.QueryDelegationsRequest) (*types.QueryDelegationsResponse, error) {
	if req == nil {
		return nil, status.Error(codes.InvalidArgument, "invalid request")
	}
	// Define a variable that will store a list of posts
	var delegations []*types.Delegation
	// Get context with the information about the environment
	ctx := sdk.UnwrapSDKContext(goCtx)
	// Get the key-value module store using the store key (in our case store key is "chain")
	store := ctx.KVStore(k.storeKey)

	iter := sdk.KVStorePrefixIterator(store, []byte(types.DelegationKey))
	defer iter.Close()

	for ; iter.Valid(); iter.Next() {
		var delegation = types.Delegation{Delegator: sdk.AccAddress(iter.Key()[len(types.DelegationKey):]).String(),
			Delegatee: sdk.AccAddress(iter.Value()).String()}
		delegations = append(delegations, &delegation)
	}

	return &types.QueryDelegationsResponse{Delegation: delegations}, nil
}
