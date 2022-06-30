package types

import (
	sdk "github.com/cosmos/cosmos-sdk/types"
	sdkerrors "github.com/cosmos/cosmos-sdk/types/errors"
)

const TypeMsgCreatePost = "create_post"

var _ sdk.Msg = &MsgCreatePost{}

func NewMsgCreatePost(author string, title string, body string) *MsgCreatePost {
	return &MsgCreatePost{
		Author: author,
		Title:  title,
		Body:   body,
	}
}

func (msg *MsgCreatePost) Route() string {
	return RouterKey
}

func (msg *MsgCreatePost) Type() string {
	return TypeMsgCreatePost
}

func (msg *MsgCreatePost) GetSigners() []sdk.AccAddress {
	author, err := sdk.AccAddressFromBech32(msg.Author)
	if err != nil {
		panic(err)
	}
	return []sdk.AccAddress{author}
}

func (msg *MsgCreatePost) GetSignBytes() []byte {
	bz := ModuleCdc.MustMarshalJSON(msg)
	return sdk.MustSortJSON(bz)
}

func (msg *MsgCreatePost) ValidateBasic() error {
	_, err := sdk.AccAddressFromBech32(msg.Author)
	if err != nil {
		return sdkerrors.Wrapf(sdkerrors.ErrInvalidAddress, "invalid creator address (%s)", err)
	}
	return nil
}
