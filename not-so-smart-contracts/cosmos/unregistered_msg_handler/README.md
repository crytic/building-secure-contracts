# Unregistered message handler

In the legacy version of the `Msg Service`, all messages have to be registered in a module keeper's `NewHandler` method. Failing to do so would prevent users from sending the not-registered message.

In [the recent Cosmos version manual registration is no longer needed](https://docs.cosmos.network/v0.47/building-modules/msg-services).

## Example

There is one message handler missing.

```go
service Msg {
  rpc ConfirmBatch(MsgConfirmBatch) returns (MsgConfirmBatchResponse) {
      option (google.api.http).post = "/gravity/v1/confirm_batch";
  }
  rpc UpdateCall(MsgUpdateCall) returns (MsgUpdateCallResponse) {
      option (google.api.http).post = "/gravity/v1/update_call";
  }
  rpc CancelCall(MsgCancelCall) returns (MsgCancelCallResponse) {
      option (google.api.http).post = "/gravity/v1/cancel_call";
  }
  rpc SetCall(MsgSetCall) returns (MsgSetCallResponse) {
      option (google.api.http).post = "/gravity/v1/set_call";
  }
  rpc SendCall(MsgSendCall) returns (MsgSendCallResponse) {
      option (google.api.http).post = "/gravity/v1/send_call";
  }
  rpc SetUserAddress(MsgSetUserAddress) returns (MsgSetUserAddressResponse) {
      option (google.api.http).post = "/gravity/v1/set_useraddress";
  }
  rpc SendUserAddress(MsgSendUserAddress) returns (MsgSendUserAddressResponse) {
      option (google.api.http).post = "/gravity/v1/send_useraddress";
  }
  rpc RequestBatch(MsgRequestBatch) returns (MsgRequestBatchResponse) {
      option (google.api.http).post = "/gravity/v1/request_batch";
  }
  rpc RequestCall(MsgRequestCall) returns (MsgRequestCallResponse) {
      option (google.api.http).post = "/gravity/v1/request_call";
  }
  rpc RequestUserAddress(MsgRequestUserAddress) returns (MsgRequestUserAddressResponse) {
      option (google.api.http).post = "/gravity/v1/request_useraddress";
  }
  rpc ConfirmEthClaim(MsgConfirmEthClaim) returns (MsgConfirmEthClaimResponse) {
      option (google.api.http).post = "/gravity/v1/confirm_ethclaim";
  }
  rpc UpdateEthClaim(MsgUpdateEthClaim) returns (MsgUpdateEthClaimResponse) {
      option (google.api.http).post = "/gravity/v1/update_ethclaim";
  }
  rpc SetBatch(MsgSetBatch) returns (MsgSetBatchResponse) {
      option (google.api.http).post = "/gravity/v1/set_batch";
  }
  rpc SendBatch(MsgSendBatch) returns (MsgSendBatchResponse) {
      option (google.api.http).post = "/gravity/v1/send_batch";
  }
  rpc CancelUserAddress(MsgCancelUserAddress) returns (MsgCancelUserAddressResponse) {
      option (google.api.http).post = "/gravity/v1/cancel_useraddress";
  }
  rpc CancelEthClaim(MsgCancelEthClaim) returns (MsgCancelEthClaimResponse) {
      option (google.api.http).post = "/gravity/v1/cancel_ethclaim";
  }
  rpc RequestEthClaim(MsgRequestEthClaim) returns (MsgRequestEthClaimResponse) {
      option (google.api.http).post = "/gravity/v1/request_ethclaim";
  }
  rpc UpdateBatch(MsgUpdateBatch) returns (MsgUpdateBatchResponse) {
      option (google.api.http).post = "/gravity/v1/update_batch";
  }
  rpc SendEthClaim(MsgSendEthClaim) returns (MsgSendEthClaimResponse) {
      option (google.api.http).post = "/gravity/v1/send_ethclaim";
  }
  rpc SetEthClaim(MsgSetEthClaim) returns (MsgSetEthClaimResponse) {
      option (google.api.http).post = "/gravity/v1/set_ethclaim";
  }
  rpc CancelBatch(MsgCancelBatch) returns (MsgCancelBatchResponse) {
      option (google.api.http).post = "/gravity/v1/cancel_batch";
  }
  rpc UpdateUserAddress(MsgUpdateUserAddress) returns (MsgUpdateUserAddressResponse) {
      option (google.api.http).post = "/gravity/v1/update_useraddress";
  }
  rpc ConfirmCall(MsgConfirmCall) returns (MsgConfirmCallResponse) {
      option (google.api.http).post = "/gravity/v1/confirm_call";
  }
  rpc ConfirmUserAddress(MsgConfirmUserAddress) returns (MsgConfirmUserAddressResponse) {
      option (google.api.http).post = "/gravity/v1/confirm_useraddress";
  }
}
```

```go
func NewHandler(k keeper.Keeper) sdk.Handler {
    msgServer := keeper.NewMsgServerImpl(k)

    return func(ctx sdk.Context, msg sdk.Msg) (*sdk.Result, error) {
        ctx = ctx.WithEventManager(sdk.NewEventManager())
        switch msg := msg.(type) {
        case *types.MsgSetBatch:
            res, err := msgServer.SetBatch(sdk.WrapSDKContext(ctx), msg)
            return sdk.WrapServiceResult(ctx, res, err)
        case *types.MsgUpdateUserAddress:
            res, err := msgServer.UpdateUserAddress(sdk.WrapSDKContext(ctx), msg)
            return sdk.WrapServiceResult(ctx, res, err)
        case *types.MsgUpdateCall:
            res, err := msgServer.UpdateCall(sdk.WrapSDKContext(ctx), msg)
            return sdk.WrapServiceResult(ctx, res, err)
        case *types.MsgSendBatch:
            res, err := msgServer.SendBatch(sdk.WrapSDKContext(ctx), msg)
            return sdk.WrapServiceResult(ctx, res, err)
        case *types.MsgCancelUserAddress:
            res, err := msgServer.CancelUserAddress(sdk.WrapSDKContext(ctx), msg)
            return sdk.WrapServiceResult(ctx, res, err)
        case *types.MsgRequestBatch:
            res, err := msgServer.RequestBatch(sdk.WrapSDKContext(ctx), msg)
            return sdk.WrapServiceResult(ctx, res, err)
        case *types.MsgUpdateEthClaim:
            res, err := msgServer.UpdateEthClaim(sdk.WrapSDKContext(ctx), msg)
            return sdk.WrapServiceResult(ctx, res, err)
        case *types.MsgSendCall:
            res, err := msgServer.SendCall(sdk.WrapSDKContext(ctx), msg)
            return sdk.WrapServiceResult(ctx, res, err)
        case *types.MsgSetCall:
            res, err := msgServer.SetCall(sdk.WrapSDKContext(ctx), msg)
            return sdk.WrapServiceResult(ctx, res, err)
        case *types.MsgCancelEthClaim:
            res, err := msgServer.CancelEthClaim(sdk.WrapSDKContext(ctx), msg)
            return sdk.WrapServiceResult(ctx, res, err)
        case *types.MsgConfirmEthClaim:
            res, err := msgServer.ConfirmEthClaim(sdk.WrapSDKContext(ctx), msg)
            return sdk.WrapServiceResult(ctx, res, err)
        case *types.MsgConfirmCall:
            res, err := msgServer.ConfirmCall(sdk.WrapSDKContext(ctx), msg)
            return sdk.WrapServiceResult(ctx, res, err)
        case *types.MsgRequestCall:
            res, err := msgServer.RequestCall(sdk.WrapSDKContext(ctx), msg)
            return sdk.WrapServiceResult(ctx, res, err)
        case *types.MsgConfirmUserAddress:
            res, err := msgServer.ConfirmUserAddress(sdk.WrapSDKContext(ctx), msg)
            return sdk.WrapServiceResult(ctx, res, err)
        case *types.MsgRequestUserAddress:
            res, err := msgServer.RequestUserAddress(sdk.WrapSDKContext(ctx), msg)
            return sdk.WrapServiceResult(ctx, res, err)
        case *types.MsgSendEthClaim:
            res, err := msgServer.SendEthClaim(sdk.WrapSDKContext(ctx), msg)
            return sdk.WrapServiceResult(ctx, res, err)
        case *types.MsgSetEthClaim:
            res, err := msgServer.SetEthClaim(sdk.WrapSDKContext(ctx), msg)
            return sdk.WrapServiceResult(ctx, res, err)
        case *types.MsgCancelBatch:
            res, err := msgServer.CancelBatch(sdk.WrapSDKContext(ctx), msg)
            return sdk.WrapServiceResult(ctx, res, err)
        case *types.MsgSetUserAddress:
            res, err := msgServer.SetUserAddress(sdk.WrapSDKContext(ctx), msg)
            return sdk.WrapServiceResult(ctx, res, err)
        case *types.MsgRequestEthClaim:
            res, err := msgServer.RequestEthClaim(sdk.WrapSDKContext(ctx), msg)
            return sdk.WrapServiceResult(ctx, res, err)
        case *types.MsgConfirmBatch:
            res, err := msgServer.ConfirmBatch(sdk.WrapSDKContext(ctx), msg)
            return sdk.WrapServiceResult(ctx, res, err)
        case *types.MsgUpdateBatch:
            res, err := msgServer.UpdateBatch(sdk.WrapSDKContext(ctx), msg)
            return sdk.WrapServiceResult(ctx, res, err)
        case *types.MsgSendUserAddress:
            res, err := msgServer.SendUserAddress(sdk.WrapSDKContext(ctx), msg)
            return sdk.WrapServiceResult(ctx, res, err)

        default:
            return nil, sdkerrors.Wrap(sdkerrors.ErrUnknownRequest, fmt.Sprintf("Unrecognized Gravity Msg type: %v", msg.Type()))
        }
    }
}
```

And it is the `CancelCall` msg.

## Mitigations

- Use the recent Msg Service mechanism
- Test all functionalities
- Deploy static-analysis tests in CI pipeline for all manually maintained code that must be repeated in multiple files/methods

## External examples

- The bug occured in the [Gravity Bridge](https://github.com/code-423n4/2021-08-gravitybridge-findings/issues/64). It was impossible to send evidence of malicious behavior, which impacted Gravity Bridge's security model.
