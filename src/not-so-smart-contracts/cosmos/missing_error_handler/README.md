# Missing error handler

The idiomatic way of handling errors in `Go` is to compare the returned error to nil. This way of checking for errors gives the programmer a lot of control. However, when error handling is ignored it can also lead to numerous problems. The impact of this is most obvious in method calls in the `bankKeeper` module, which even causes some accounts with insufficient balances to perform `SendCoin` operations normally without triggering a transaction failure.

## Example

In the following code, `k.bankKeeper.SendCoins(ctx, sender, receiver, amount)` does not have any return values being used, including `err`. This results in `SendCoin` not being able to prevent the transaction from executing even if there is an `error` due to insufficient balance in `SendCoin`.

```golang
func (k msgServer) Transfer(goCtx context.Context, msg *types.MsgTransfer) (*types.MsgTransferResponse, error) {
	...
	k.bankKeeper.SendCoins(ctx, sender, receiver, amount)
	...
	return &types.MsgTransferResponse{}, nil
}
```

## Mitigations

- Implement the error handling process instead of missing it

## External examples

- [ignite's tutorials](https://github.com/ignite/cli/issues/2828).
- [Fadeev's Loan Project](https://github.com/fadeev/loan/blob/master/x/loan/keeper/msg_server_approve_loan.go)
- [JackalLabs](https://github.com/JackalLabs/canine-chain/issues/8).
- [OllO](https://github.com/OllO-Station/ollo/issues/20)
