# Unregistered Message Handler

In the legacy version of the `Msg Service`, every message must be registered within a module keeper's `NewHandler` method. Failure to register a message would prevent users from sending the unregistered message.

In [the recent Cosmos version, manual registration is no longer needed](https://docs.cosmos.network/v0.47/building-modules/msg-services).

## Example

In the code below, one message handler is missing.

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
...
```

The missing message is the `CancelCall` msg.

## Mitigations

- Use the recent Msg Service mechanism.
- Test all functionalities.
- Deploy static-analysis tests in the CI pipeline for all manually maintained code that must be repeated in multiple files/methods.

## External examples

- The bug occurred in the [Gravity Bridge](https://github.com/code-423n4/2021-08-gravitybridge-findings/issues/64). It was impossible to send evidence of malicious behavior, which impacted Gravity Bridge's security model.
