# Incorrect Signers

In Cosmos, transaction's signature(s) are validated against public keys (addresses) taken from the transaction itself,
where locations of the keys [are specified in `GetSigners` methods](https://docs.cosmos.network/v0.46/core/transactions.html#signing-transactions).

In the simplest case there is just one signer required, and its address is simple to use correctly.
However, in more complex scenarios like when multiple signatures are required or a delegation schema is implemented,
it is possible to make mistakes about what addresses in the transaction (the message) are actually authenticated.

Fortunately, mistakes in `GetSigners` should make part of application's intended functionality not working,
making it easy to spot the bug.

## Example

The example application allows an author to create posts. A post can be created with a `MsgCreatePost` message, which has `signer` and `author` fields.

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

The `signer` field is used for signature verification - as can be seen in `GetSigners` method below.

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

The `author` field is saved along with the post's content:

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

The bug here - mismatch between the message signer address and the stored address - allows users to impersonate other users by sending an arbitrary `author` field.

## Mitigations

- Keep signers-related logic simple
- Implement basic sanity tests for all functionalities
