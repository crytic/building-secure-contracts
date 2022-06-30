package keeper_test

import (
	"testing"

	"github.com/stretchr/testify/require"
	testkeeper "github.com/trailofbits/incorrect_getsigners/testutil/keeper"
	"github.com/trailofbits/incorrect_getsigners/x/incorrectgetsigners/types"
)

func TestGetParams(t *testing.T) {
	k, ctx := testkeeper.IncorrectgetsignersKeeper(t)
	params := types.DefaultParams()

	k.SetParams(ctx, params)

	require.EqualValues(t, params, k.GetParams(ctx))
}
