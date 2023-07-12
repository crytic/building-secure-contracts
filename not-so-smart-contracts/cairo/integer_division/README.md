# Integer Division

Math in Cairo is done in a finite field, which explains why the numeric type is called `felt` for field elements. In most cases, addition, subtraction, and multiplication will behave like standard integer operations when writing Cairo code. However, developers need to pay extra attention when performing division. Unlike in Solidity, where division is carried out as if the values were real numbers and anything after the decimal place is truncated, in Cairo, it's more intuitive to think of division as the inverse of multiplication. When a number divides a whole number of times into another number, the result is what we would expect, such as 30/6=5. However, if we try to divide numbers that don't quite match up so perfectly, like 30/9, the result might be surprising, such as 1206167596222043737899107594365023368541035738443865566657697352045290673497. That's because 120...97 \* 9 = 30 (modulo the [252-bit prime used by StarkNet](https://docs.starkware.co/starkex-v4/crypto/stark-curve)).

## Example

Consider the following functions that normalize a user's token balance to a human-readable value for a token with 10^18 decimals. In the first function, it will provide meaningful values only when a user has a whole number of tokens and will return nonsensical values in every other case. The better version stores these values as Uint256s and employs more traditional integer division.

```cairo
@external
func bad_normalize_tokens{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}() -> (
    normalized_balance: felt
) {
    let (user) = get_caller_address();

    let (user_current_balance) = user_balances.read(user);
    let (normalized_balance) = user_current_balance / 10 ** 18;

    return (normalized_balance,);
}

@external
func better_normalize_tokens{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}() -> (
    normalized_balance: Uint256
) {
    let (user) = get_caller_address();

    let (user_current_balance) = user_balances.read(user);
    let (normalized_balance, _) = uint256_unsigned_div_rem(user_current_balance, 10 ** 18);

    return (normalized_balance,);
}
```

## Mitigations

- Review the most appropriate numeric type for your use case. Especially if your programs rely on division, consider using [the uint256 module](https://github.com/starkware-libs/cairo-lang/blob/master/src/starkware/cairo/common/uint256.cairo) instead of the felt primitive type.

## External Examples
