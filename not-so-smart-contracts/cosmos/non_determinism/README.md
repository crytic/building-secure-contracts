# Non-determinism

Non-determinism in consensus-relevant code can cause the blockchain to halt. Various sources of non-determinism exist, with some specific to the Go language:

- [`range` iterations over an unordered map or other operations involving unordered structures](https://lev.pm/posts/2020-04-18-golang-map-randomness/)
- [Implementation (platform) dependent types like `int`](https://go.dev/ref/spec#Numeric_types) or `filepath.Ext`
- [goroutines and `select` statement](https://github.com/golang/go/issues/33702)
- [Memory addresses](https://github.com/cosmos/cosmos-sdk/issues/11726#issuecomment-1108427164)
- [Floating point arithmetic operations](https://en.wikipedia.org/wiki/Floating-point_arithmetic#Accuracy_problems)
- Randomness ([may be problematic even with a constant seed](https://github.com/golang/go/issues/42701))
- Local time and timezones
- Packages like `unsafe`, `reflect`, and `runtime`

## Example

The following example demonstrates an iteration over a `map` of `amounts`. If `k.GetPool` fails for more than one `asset`, different nodes will produce different errors, causing the chain to halt.

```go
func (k msgServer) CheckAmounts(goCtx context.Context, msg *types.MsgCheckAmounts) (*types.MsgCheckAmountsResponse, error) {
    ctx := sdk.UnwrapSDKContext(goCtx)

    amounts := make(map[Asset]int)
    for asset, coin := range allMoney.Coins {
        amounts[asset] = Compute(coin)
    }

    total int := 0
    for asset, f := range amounts {
        poolSize, err := k.GetPool(ctx, asset, f)
        if err != nil {
            return nil, err
        }
        total += poolSize
    }

    if total == 0 {
        return nil, errors.New("Zero total")
    }

    return &types.MsgCheckAmountsResponse{}, nil
}
```

Even after fixing the `map` issue, the `total` overflow may occur for nodes running on 32-bit architectures earlier than others, causing a chain split.

## Mitigations

- Use static analysis, for example [custom CodeQL rules](https://github.com/crypto-com/cosmos-sdk-codeql)
- Test your application with nodes running on various architectures or require nodes to run on a specific one
- Develop and test procedures for recovering from a blockchain split

## External examples

- [ThorChain halted due to "iteration over a map error-ing at different indexes"](https://gitlab.com/thorchain/thornode/-/issues/1169)
- [Cyber encountered problems with the `float64` type](https://github.com/cybercongress/go-cyber/issues/66)
