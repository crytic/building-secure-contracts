# ABCI methods panic

A `panic` inside an ABCI method (e.g., `EndBlocker`) will stop the chain. There should be no unanticipated `panic`s in these methods.

Some less expected `panic` sources are:

- [`Coins`, `DecCoins`, `Dec`, `Int`, and `UInt` types panics a lot](https://github.com/cosmos/cosmos-sdk/blob/afbb0bd1941f7ad36e086913153af02eb6a68f5a/types/coin.go#L68), [for example on overflows](https://github.com/cosmos/cosmos-sdk/blob/afbb0bd1941f7ad36e086913153af02eb6a68f5a/types/dec_coin.go#L105) and [rounding errors](https://github.com/cosmos/cosmos-sdk/blob/afbb0bd1941f7ad36e086913153af02eb6a68f5a/types/decimal.go#L648)
- [`new Dec` panics](https://pkg.go.dev/github.com/cosmos/cosmos-sdk/types@v0.45.5#Dec)
- [`x/params`'s `SetParamSet` panics if arguments are invalid](https://github.com/cosmos/cosmos-sdk/blob/1b1dbf8ab722e4689e14a5a2a1fc433b69bc155e/x/params/doc.go#L107-L108)

## Example

The application below enforces limits on how much coins can be borrowed globally. If the `loan.Borrowed` array of Coins can be forced to be not-sorted (by coins' denominations), the `Add` method will `panic`.

Moreover, the `Mul` may panic if some asset's price becomes large.

```go
func BeginBlocker(ctx sdk.Context, k keeper.Keeper) {
    if !validateTotalBorrows(ctx, k) {
        k.PauseNewLoans(ctx)
    }
}

func validateTotalBorrows(ctx sdk.Context, k keeper.Keeper) {
    total := sdk.NewCoins()
    for _, loan := range k.GetUsersLoans() {
        total.Add(loan.Borrowed...)
    }

    for _, totalOneAsset := range total {
        if totalOneAsset.Amount.Mul(k.GetASsetPrice(totalOneAsset.Denom)).GTE(k.GetGlobalMaxBorrow()) {
            return false
        }
    }
    return true
}
```

## Mitigations

- [Use CodeQL static analysis](https://github.com/crypto-com/cosmos-sdk-codeql/blob/main/src/beginendblock-panic.ql) to detect `panic`s in ABCI methods
- Review the code against unexpected `panic`s

## External examples

- [Gravity Bridge can `panic` in multiple locations in the `EndBlocker` method](https://giters.com/althea-net/cosmos-gravity-bridge/issues/348)
- [Agoric `panic`s purposefully if the `PushAction` method returns an error](https://github.com/Agoric/agoric-sdk/blob/9116ede69169ebb252faf069d90022e8e05c6a4e/golang/cosmos/x/vbank/module.go#L166)
- [Setting invalid parameters in `x/distribution` module causes `panic` in `BeginBlocker`](https://github.com/cosmos/cosmos-sdk/issues/5808). Valid parameters are [described in the documentation](https://docs.cosmos.network/v0.45/modules/distribution/07_params.html).
