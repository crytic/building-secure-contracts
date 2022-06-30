package simulation

import (
	"math/rand"

	"github.com/cosmos/cosmos-sdk/baseapp"
	sdk "github.com/cosmos/cosmos-sdk/types"
	simtypes "github.com/cosmos/cosmos-sdk/types/simulation"
	"github.com/trailofbits/incorrect_getsigners/x/incorrectgetsigners/keeper"
	"github.com/trailofbits/incorrect_getsigners/x/incorrectgetsigners/types"
)

func SimulateMsgCreatePost(
	ak types.AccountKeeper,
	bk types.BankKeeper,
	k keeper.Keeper,
) simtypes.Operation {
	return func(r *rand.Rand, app *baseapp.BaseApp, ctx sdk.Context, accs []simtypes.Account, chainID string,
	) (simtypes.OperationMsg, []simtypes.FutureOperation, error) {
		simAccount, _ := simtypes.RandomAcc(r, accs)
		msg := &types.MsgCreatePost{
			Author: simAccount.Address.String(),
		}

		// TODO: Handling the CreatePost simulation

		return simtypes.NoOpMsg(types.ModuleName, msg.Type(), "CreatePost simulation not implemented"), nil, nil
	}
}
