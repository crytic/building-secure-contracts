# Rounding Errors

Application developers must pay attention to the correct rounding of numbers, particularly if the rounding affects token amounts.

Cosmos-sdk provides two custom types for handling numbers:

- `sdk.Int` (`sdk.UInt`) type for integral numbers
- `sdk.Dec` type for decimal arithmetic

The `sdk.Dec` type [has issues with precision and does not guarantee associativity](https://github.com/cosmos/cosmos-sdk/issues/7773), so it must be used cautiously. However, even if a more robust library for decimal numbers is implemented in the cosmos-sdk, rounding might still be unavoidable.

## Example

The simple example below demonstrates the precision problems with the `sdk.Dec` type.

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

- Ensure that all token operations requiring rounded results always benefit the system (application) and not the users. In other words, consistently choose the correct rounding direction. See [Appendix G in the Umee audit report](https://github.com/trailofbits/publications/blob/master/reviews/Umee.pdf).

- Use the "multiplication before division" pattern. In other words, instead of computing `(x / y) * z`, perform `(x * z) / y`.

- Monitor [issue #11783](https://github.com/cosmos/cosmos-sdk/issues/11783) for a replacement of the `sdk.Dec` type.

## External Examples

- [Umee experienced a vulnerability caused by an incorrect rounding direction](https://github.com/umee-network/umee/issues/545).
