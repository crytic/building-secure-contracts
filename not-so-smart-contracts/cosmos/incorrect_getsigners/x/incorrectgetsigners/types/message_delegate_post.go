package types

import (
	sdk "github.com/cosmos/cosmos-sdk/types"
	sdkerrors "github.com/cosmos/cosmos-sdk/types/errors"
)

const TypeMsgDelegatePost = "delegate_post"

var _ sdk.Msg = &MsgDelegatePost{}

func NewMsgDelegatePost(delegator string, delegatee string, post *Post) *MsgDelegatePost {
	return &MsgDelegatePost{
		Delegator: delegator,
		Delegatee: delegatee,
		Post:      post,
	}
}

func (msg *MsgDelegatePost) Route() string {
	return RouterKey
}

func (msg *MsgDelegatePost) Type() string {
	return TypeMsgDelegatePost
}

func (msg *MsgDelegatePost) GetSigners() []sdk.AccAddress {
	delegator, err := sdk.AccAddressFromBech32(msg.Delegator)
	if err != nil {
		panic(err)
	}
	return []sdk.AccAddress{delegator}
}

func (msg *MsgDelegatePost) GetSignBytes() []byte {
	bz := ModuleCdc.MustMarshalJSON(msg)
	return sdk.MustSortJSON(bz)
}

func (msg *MsgDelegatePost) ValidateBasic() error {
	_, err := sdk.AccAddressFromBech32(msg.Delegator)
	if err != nil {
		return sdkerrors.Wrapf(sdkerrors.ErrInvalidAddress, "invalid delegator address (%s)", err)
	}
	_, err = sdk.AccAddressFromBech32(msg.Delegatee)
	if err != nil {
		return sdkerrors.Wrapf(sdkerrors.ErrInvalidAddress, "invalid delegatee address (%s)", err)
	}
	return nil
}
