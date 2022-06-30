package keeper

import (
	"context"

	sdk "github.com/cosmos/cosmos-sdk/types"
	"github.com/trailofbits/incorrect_getsigners/x/incorrectgetsigners/types"
)

func (k msgServer) Delegate(goCtx context.Context, msg *types.MsgDelegate) (*types.MsgDelegateResponse, error) {
	ctx := sdk.UnwrapSDKContext(goCtx)

	delegatorAddr, err := sdk.AccAddressFromBech32(msg.Delegator)
	if err != nil {
		return nil, err
	}

	delegateeAddr, err := sdk.AccAddressFromBech32(msg.Delegatee)
	if err != nil {
		return nil, err
	}

	k.SetDelegation(ctx, delegatorAddr, delegateeAddr)

	return &types.MsgDelegateResponse{}, nil
}
