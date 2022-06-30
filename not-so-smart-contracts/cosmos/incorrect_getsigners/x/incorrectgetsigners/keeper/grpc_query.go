package keeper

import (
	"github.com/trailofbits/incorrect_getsigners/x/incorrectgetsigners/types"
)

var _ types.QueryServer = Keeper{}
