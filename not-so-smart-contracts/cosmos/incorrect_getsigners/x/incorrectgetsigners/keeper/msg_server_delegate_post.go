package keeper

import (
	"context"

	sdk "github.com/cosmos/cosmos-sdk/types"
	"github.com/trailofbits/incorrect_getsigners/x/incorrectgetsigners/types"
)

func (k msgServer) DelegatePost(goCtx context.Context, msg *types.MsgDelegatePost) (*types.MsgDelegatePostResponse, error) {
	ctx := sdk.UnwrapSDKContext(goCtx)

	delegatorAddr, err := sdk.AccAddressFromBech32(msg.Delegator)
	if err != nil {
		return nil, err
	}

	delegateeAddr, err := sdk.AccAddressFromBech32(msg.Delegatee)
	if err != nil {
		return nil, err
	}

	if err := k.ValidateDelegation(ctx, delegateeAddr, delegatorAddr); err != nil {
		return nil, err
	}
	var post = msg.Post
	post.Author = msg.Delegatee

	//var post = types.Post{
	//	Author: msg.Delegatee,
	//	Title:  msg.Title,
	//	Body:   msg.Body,
	//}

	id := k.AppendPost(ctx, *post)

	return &types.MsgDelegatePostResponse{Id: id}, nil
}
