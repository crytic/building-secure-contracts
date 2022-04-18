# Integer Division

Math in Cairo is done in a finite field, which is why the numeric type is called `felt`, for field elements. In most cases addition, subtraction and multiplication will behave as they would in standard integer operations when writing Cairo code. However, developers need to pay a little bit extra attention when performing division. Unlike in Solidity, where division is carried out as if the values were real numbers and anything after the decimal place is truncated, in Cairo it's more intuitive to think of division as the inverse of multiplication. When a number divides a whole number of times into another number, the result is what we would expect, for example 30/6=5. But if we try to divide numbers that don't quite match up so perfectly, like 30/9, the result can be a bit surprising, in this case 1206167596222043737899107594365023368541035738443865566657697352045290673497. That's because 120...97 * 9  = 30 (modulo the [252-bit prime used by StarkNet](https://docs.starkware.co/starkex-v4/crypto/stark-curve))

## Attack Scenarios


## Mitigations

- Review which numeric type is most appropriate for your use case. Especially if your programs rely on division, consider using [the uint256 module](https://github.com/starkware-libs/cairo-lang/blob/master/src/starkware/cairo/common/uint256.cairo) instead of the felt primitive type.

## Examples

- In [incorrect_division_1](incorrect_division_1.cairo), we give both unsafe and safe examples of
the division operation.