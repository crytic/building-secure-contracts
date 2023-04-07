# Rounding errors

Application developers must take care of correct rounding of numbers, especially if the rounding impacts tokens amounts.

Cosmos-sdk offers two custom types for dealing with numbers:

- `sdk.Int` (`sdk.UInt`) type for integral numbers
- `sdk.Dec` type for decimal arithmetic

The `sdk.Dec` type [has problems with precision and does not guarantee associativity](https://github.com/cosmos/cosmos-sdk/issues/7773), so it must be used carefully. But even if a more robust library for decimal numbers is deployed in the cosmos-sdk, rounding may be unavoidable.

## Example

Below we see a simple example demonstrating `sdk.Dec` type's precision problems.

```go
func TestDec() {
    a := sdk.MustNewDecFromStr("10")
    b := sdk.MustNewDecFromStr("1000000010")
    x := a.Quo(b).Mul(b)
    fmt.Println(x)  // 9.999999999999999000

    q := float32(10)
    w := float32(1000000010)
    y := (q / w) * w
    fmt.Println(y)  // 10
}
```

## Mitigations

- Ensure that all tokens operations that must round results always benefit the system (application) and not users. In other words, always decide on the correct rounding direction. See [Appendix G in the Umee audit report](https://github.com/trailofbits/publications/blob/master/reviews/Umee.pdf)

- Apply "multiplication before division" pattern. That is, instead of computing `(x / y) * z` do `(x * z) / y`

- Observe [issue #11783](https://github.com/cosmos/cosmos-sdk/issues/11783) for a replacement of the `sdk.Dec` type

## External examples

- [Umee had vulnerability caused by incorrect rounding direction](https://github.com/umee-network/umee/issues/545)
