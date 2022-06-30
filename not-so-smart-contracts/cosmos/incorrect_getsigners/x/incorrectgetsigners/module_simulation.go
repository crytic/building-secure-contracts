package incorrectgetsigners

import (
	"math/rand"

	"github.com/cosmos/cosmos-sdk/baseapp"
	simappparams "github.com/cosmos/cosmos-sdk/simapp/params"
	sdk "github.com/cosmos/cosmos-sdk/types"
	"github.com/cosmos/cosmos-sdk/types/module"
	simtypes "github.com/cosmos/cosmos-sdk/types/simulation"
	"github.com/cosmos/cosmos-sdk/x/simulation"
	"github.com/trailofbits/incorrect_getsigners/testutil/sample"
	incorrectgetsignerssimulation "github.com/trailofbits/incorrect_getsigners/x/incorrectgetsigners/simulation"
	"github.com/trailofbits/incorrect_getsigners/x/incorrectgetsigners/types"
)

// avoid unused import issue
var (
	_ = sample.AccAddress
	_ = incorrectgetsignerssimulation.FindAccount
	_ = simappparams.StakePerAccount
	_ = simulation.MsgEntryKind
	_ = baseapp.Paramspace
)

const (
	opWeightMsgCreatePost = "op_weight_msg_create_post"
	// TODO: Determine the simulation weight value
	defaultWeightMsgCreatePost int = 100

	opWeightMsgDelegate = "op_weight_msg_delegate"
	// TODO: Determine the simulation weight value
	defaultWeightMsgDelegate int = 100

	opWeightMsgDelegatePost = "op_weight_msg_delegate_post"
	// TODO: Determine the simulation weight value
	defaultWeightMsgDelegatePost int = 100

	// this line is used by starport scaffolding # simapp/module/const
)

// GenerateGenesisState creates a randomized GenState of the module
func (AppModule) GenerateGenesisState(simState *module.SimulationState) {
	accs := make([]string, len(simState.Accounts))
	for i, acc := range simState.Accounts {
		accs[i] = acc.Address.String()
	}
	incorrectgetsignersGenesis := types.GenesisState{
		Params: types.DefaultParams(),
		// this line is used by starport scaffolding # simapp/module/genesisState
	}
	simState.GenState[types.ModuleName] = simState.Cdc.MustMarshalJSON(&incorrectgetsignersGenesis)
}

// ProposalContents doesn't return any content functions for governance proposals
func (AppModule) ProposalContents(_ module.SimulationState) []simtypes.WeightedProposalContent {
	return nil
}

// RandomizedParams creates randomized  param changes for the simulator
func (am AppModule) RandomizedParams(_ *rand.Rand) []simtypes.ParamChange {

	return []simtypes.ParamChange{}
}

// RegisterStoreDecoder registers a decoder
func (am AppModule) RegisterStoreDecoder(_ sdk.StoreDecoderRegistry) {}

// WeightedOperations returns the all the gov module operations with their respective weights.
func (am AppModule) WeightedOperations(simState module.SimulationState) []simtypes.WeightedOperation {
	operations := make([]simtypes.WeightedOperation, 0)

	var weightMsgCreatePost int
	simState.AppParams.GetOrGenerate(simState.Cdc, opWeightMsgCreatePost, &weightMsgCreatePost, nil,
		func(_ *rand.Rand) {
			weightMsgCreatePost = defaultWeightMsgCreatePost
		},
	)
	operations = append(operations, simulation.NewWeightedOperation(
		weightMsgCreatePost,
		incorrectgetsignerssimulation.SimulateMsgCreatePost(am.accountKeeper, am.bankKeeper, am.keeper),
	))

	var weightMsgDelegate int
	simState.AppParams.GetOrGenerate(simState.Cdc, opWeightMsgDelegate, &weightMsgDelegate, nil,
		func(_ *rand.Rand) {
			weightMsgDelegate = defaultWeightMsgDelegate
		},
	)
	operations = append(operations, simulation.NewWeightedOperation(
		weightMsgDelegate,
		incorrectgetsignerssimulation.SimulateMsgDelegate(am.accountKeeper, am.bankKeeper, am.keeper),
	))

	var weightMsgDelegatePost int
	simState.AppParams.GetOrGenerate(simState.Cdc, opWeightMsgDelegatePost, &weightMsgDelegatePost, nil,
		func(_ *rand.Rand) {
			weightMsgDelegatePost = defaultWeightMsgDelegatePost
		},
	)
	operations = append(operations, simulation.NewWeightedOperation(
		weightMsgDelegatePost,
		incorrectgetsignerssimulation.SimulateMsgDelegatePost(am.accountKeeper, am.bankKeeper, am.keeper),
	))

	// this line is used by starport scaffolding # simapp/module/operation

	return operations
}
