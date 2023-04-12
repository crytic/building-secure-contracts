# Slow ABCI Methods

ABCI methods (such as `EndBlocker`) [are not constrained by `gas`](https://docs.cosmos.network/v0.45/basics/app-anatomy.html#beginblocker-and-endblocker). Therefore, it is crucial to ensure that they always finish in a reasonable time; otherwise, the chain will halt.

## Example

Below is a part of a token lending application. The `BeginBlocker` method charges interest for each borrower before a block is executed.

```go
func BeginBlocker(ctx sdk.Context, k keeper.Keeper) {
    updatePrices(ctx, k)
    accrueInterest(ctx, k)
}

func accrueInterest(ctx sdk.Context, k keeper.Keeper) {
    for _, pool := range k.GetLendingPools() {
        poolAssets := k.GetPoolAssets(ctx, pool.Id)
        for userId, _ := range k.GetAllUsers() {
            for _, asset := range poolAssets {
                for _, loan := range k.GetUserLoans(ctx, pool, asset, userId) {
                    if err := k.AccrueInterest(ctx, loan); err != nil {
                        k.PunishUser(ctx, userId)
                    }
                }
            }
        }
    }
}
```

The `accrueInterest` function contains multiple nested for loops, making it too complex to be efficient. Malicious users can take many small loans to slow down computation to the point where the chain cannot keep up with block production and halts.

## Mitigations

- Estimate the computational complexity of all implemented ABCI methods and ensure that they will scale correctly with the application's usage growth.
- Implement stress tests for the ABCI methods.
- [Ensure that minimal fees are enforced on all messages](https://docs.cosmos.network/v0.46/basics/gas-fees.html#introduction-to-gas-and-fees) to prevent spam.

## External Examples

- [Gravity Bridge's `slashing` method was executed in the `EndBlocker` and contained a computationally expensive, nested loop](https://github.com/althea-net/cosmos-gravity-bridge/issues/347).
