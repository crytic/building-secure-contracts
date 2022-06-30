package incorrectgetsigners_test

import (
	"testing"

	"github.com/stretchr/testify/require"
	keepertest "github.com/trailofbits/incorrect_getsigners/testutil/keeper"
	"github.com/trailofbits/incorrect_getsigners/testutil/nullify"
	"github.com/trailofbits/incorrect_getsigners/x/incorrectgetsigners"
	"github.com/trailofbits/incorrect_getsigners/x/incorrectgetsigners/types"
)

func TestGenesis(t *testing.T) {
	genesisState := types.GenesisState{
		Params: types.DefaultParams(),

		// this line is used by starport scaffolding # genesis/test/state
	}

	k, ctx := keepertest.IncorrectgetsignersKeeper(t)
	incorrectgetsigners.InitGenesis(ctx, *k, genesisState)
	got := incorrectgetsigners.ExportGenesis(ctx, *k)
	require.NotNil(t, got)

	nullify.Fill(&genesisState)
	nullify.Fill(got)

	// this line is used by starport scaffolding # genesis/test/assert
}
