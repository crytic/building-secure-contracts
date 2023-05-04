# Non-determinism

Non-determinism in conensus-relevant code will cause the blockchain to halt.
There are quite a few sources of non-determinism, some of which are specific to the Go language:

- [`range` iterations over an unordered map or other operations involving unordered structures](https://go.dev/blog/maps#iteration-order)
- [Implementation (platform) dependent types like `int`](https://go.dev/ref/spec#Numeric_types) or `filepath.Ext`
- [goroutines and `select` statement](https://github.com/golang/go/issues/33702)
- [Memory addresses](https://github.com/cosmos/cosmos-sdk/issues/11726#issuecomment-1108427164)
- [Floating point arithmetic operations](https://en.wikipedia.org/wiki/Floating-point_arithmetic#Accuracy_problems)
- Randomness ([may be problematic even with a constant seed](https://github.com/golang/go/issues/42701))
- Local time and timezones
- Packages like `unsafe`, `reflect`, and `runtime`

## Example

Below we can see an iteration over a `amounts` `map`. If `k.GetPool` fails for more than one `asset`, then different nodes will fail with different errors, causing the chain to halt.

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

Even if we fix the `map` problem, it is still possible that the `total` overflows for nodes running on 32-bit architectures earlier than for the rest of the nodes, again causing the chain split.

## Mitigations

- Use static analysis, for example [custom CodeQL rules](https://github.com/crypto-com/cosmos-sdk-codeql)
- Test your application with nodes running on various architectures or require nodes to run on a specific one
- Prepare and test procedures for recovering from a blockchain split

## External examples

- [ThorChain halt due to "iteration over a map error-ing at different indexes"](https://gitlab.com/thorchain/thornode/-/issues/1169)
- [Cyber's had problems with `float64` type](https://github.com/cybercongress/go-cyber/issues/66)
