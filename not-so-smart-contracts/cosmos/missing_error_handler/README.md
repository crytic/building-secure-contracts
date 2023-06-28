# Missing Error Handler

The idiomatic way of handling errors in `Go` involves comparing the returned error to nil. This error-checking method provides the programmer with a significant level of control. However, ignoring error handling can result in various issues. The effects are particularly evident in method calls in the `bankKeeper` module, where some accounts with insufficient balances still carry out `SendCoin` operations normally, without triggering a transaction failure.

## Example

In the code snippet below, `k.bankKeeper.SendCoins(ctx, sender, receiver, amount)` does not utilize any return values, including `err`. Consequently, `SendCoin` cannot prevent the transaction from executing, even if there is an `error` caused by an insufficient balance in `SendCoin`.

```golang
func (k msgServer) Transfer(goCtx context.Context, msg *types.MsgTransfer) (*types.MsgTransferResponse, error) {
	...
	k.bankKeeper.SendCoins(ctx, sender, receiver, amount)
	...
	return &types.MsgTransferResponse{}, nil
}
```

## Mitigations

- Implement the error handling process, rather than omitting it.

## External Examples

- [Ignite's Tutorials](https://github.com/ignite/cli/issues/2828)
- [Fadeev's Loan Project](https://github.com/fadeev/loan/blob/master/x/loan/keeper/msg_server_approve_loan.go)
- [JackalLabs](https://github.com/JackalLabs/canine-chain/issues/8)
- [OllO Station](https://github.com/OllO-Station/ollo/issues/20)
