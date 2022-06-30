package types

// DONTCOVER

import (
	sdkerrors "github.com/cosmos/cosmos-sdk/types/errors"
)

// x/incorrectgetsigners module sentinel errors
var (
	AuthError = sdkerrors.Register(ModuleName, 1100, "Authentication error")
)
