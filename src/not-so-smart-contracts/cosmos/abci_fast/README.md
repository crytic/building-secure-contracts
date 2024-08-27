# Slow ABCI methods

ABCI methods (like `EndBlocker`) [are not constrained by `gas`](https://docs.cosmos.network/v0.45/basics/app-anatomy.html#beginblocker-and-endblocker). Therefore, it is essential to ensure that they always will finish in a reasonable time. Otherwise, the chain will halt.

## Example

Below you can find part of a tokens lending application. Before a block is executed, the `BeginBlocker` method charges an interest for each borrower.

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

The `accrueInterest` contains multiple nested for loops and is obviously too complex to be efficient. Mischievous
users can take a lot of small loans to slow down computation to a point where the chain is not able to keep up with blocks production and halts.

## Mitigations

- Estimate computational complexity of all implemented ABCI methods and ensure that they will scale correctly with the application's usage growth
- Implement stress tests for the ABCI methods
- [Ensure that minimal fees are enforced on all messages](https://docs.cosmos.network/v0.46/basics/gas-fees.html#introduction-to-gas-and-fees) to prevent spam

## External examples

- [Gravity Bridge's `slashing` method was executed in the `EndBlocker` and contained a computationally expensive, nested loop](https://github.com/althea-net/cosmos-gravity-bridge/issues/347).
