# Addressing Incorrect Signers

In Cosmos, a transaction's signatures are validated against public keys (addresses) extracted from the transaction itself, with the key locations [specified in `GetSigners` methods](https://docs.cosmos.network/v0.46/core/transactions.html#signing-transactions).

For simple cases where only one signer is needed, using the correct address is straightforward. However, in more complex scenarios involving multiple signatures or delegation schemas, it's possible to make mistakes in determining which addresses in the transaction (the message) are being authenticated.

Thankfully, errors in `GetSigners` typically result in a portion of the application's intended functionality not working, making it easier to identify the issue.

## Example

Consider an example application that allows authors to create posts. A post can be created using a `MsgCreatePost` message, which includes `signer` and `author` fields.

```proto
service Msg {
      rpc CreatePost(MsgCreatePost) returns (MsgCreatePostResponse);
}

message MsgCreatePost {
  string signer = 1;
  string author = 2;
  string title = 3;
  string body = 4;
}

message MsgCreatePostResponse {
  uint64 id = 1;
}

message Post {
  string author = 1;
  uint64 id = 2;
  string title = 3;
  string body = 4;
}
```

The `signer` field is used for signature verification, as demonstrated in the `GetSigners` method below.

```go
func (msg *MsgCreatePost) GetSigners() []sdk.AccAddress {
    signer, err := sdk.AccAddressFromBech32(msg.Signer)
    if err != nil {
        panic(err)
    }
    return []sdk.AccAddress{Signer}
}

func (msg *MsgCreatePost) GetSignBytes() []byte {
    bz := ModuleCdc.MustMarshalJSON(msg)
    return sdk.MustSortJSON(bz)
}

func (msg *MsgCreatePost) ValidateBasic() error {
    _, err := sdk.AccAddressFromBech32(msg.Signer)
    if err != nil {
        return sdkerrors.Wrapf(sdkerrors.ErrInvalidAddress, "invalid creator address (%s)", err)
    }
    return nil
}
```

The `author` field is stored along with the post content:

```go
func (k msgServer) CreatePost(goCtx context.Context, msg *types.MsgCreatePost) (*types.MsgCreatePostResponse, error) {
    ctx := sdk.UnwrapSDKContext(goCtx)

    var post = types.Post{
        Author: msg.Author,
        Title:  msg.Title,
        Body:   msg.Body,
    }

    id := k.AppendPost(ctx, post)

    return &types.MsgCreatePostResponse{Id: id}, nil
}
```

In this example, the bug involves a mismatch between the message signer address and the stored address, allowing users to impersonate others by providing an arbitrary `author` field.

## Mitigation Strategies

- Keep the logic related to signers simple.
- Implement basic sanity tests for all functionalities.
