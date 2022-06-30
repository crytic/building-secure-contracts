package keeper

import (
	"context"
	sdk "github.com/cosmos/cosmos-sdk/types"
	"github.com/trailofbits/incorrect_getsigners/x/incorrectgetsigners/types"
	"google.golang.org/grpc/codes"
	"google.golang.org/grpc/status"
)

func (k Keeper) Posts(c context.Context, req *types.QueryPostsRequest) (*types.QueryPostsResponse, error) {
	// Throw an error if request is nil
	if req == nil {
		return nil, status.Error(codes.InvalidArgument, "invalid request")
	}
	// Define a variable that will store a list of posts
	var posts []*types.Post
	// Get context with the information about the environment
	ctx := sdk.UnwrapSDKContext(c)
	// Get the key-value module store using the store key (in our case store key is "chain")
	store := ctx.KVStore(k.storeKey)

	iter := sdk.KVStorePrefixIterator(store, []byte(types.PostKey))
	defer iter.Close()

	for ; iter.Valid(); iter.Next() {
		var post types.Post
		if err := k.cdc.Unmarshal(iter.Value(), &post); err != nil {
			return nil, status.Error(codes.Internal, err.Error())
		}
		posts = append(posts, &post)
	}

	// Return a struct containing a list of posts and pagination info
	return &types.QueryPostsResponse{Post: posts}, nil
}
