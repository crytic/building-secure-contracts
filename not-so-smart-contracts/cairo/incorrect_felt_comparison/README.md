# Incorrect Felt Comparison

In Cairo, the less than or equal to comparison operator has two methods: `assert_le` and `assert_nn_le`:

- `assert_le` asserts that a number `a` is less than or equal to `b`, regardless of the size of `a`
- `assert_nn_le` additionally asserts that `a` is [non-negative](https://github.com/starkware-libs/cairo-lang/blob/9889fbd522edc5eff603356e1912e20642ae20af/src/starkware/cairo/common/math.cairo#L71), essentially meaning it should be less than or equal to the `RANGE_CHECK_BOUND` value of `2^128`.

`assert_nn_le` is suitable for comparing unsigned integers with values smaller than `2^128` (e.g., an [Uint256](https://github.com/starkware-libs/cairo-lang/blob/9889fbd522edc5eff603356e1912e20642ae20af/src/starkware/cairo/common/uint256.cairo#L9-L14) field). To compare felts as unsigned integers over the entire range (0, P], use `assert_le_felt`. These functions also exist with the `is_` prefix, where they return 1 (TRUE) or 0 (FALSE).

One common mistake resulting from the complexity of these assertions is using `assert_le` instead of `assert_nn_le`.

# Example

Consider the example of a codebase that uses the following checks concerning a hypothetical ERC20 token. The first function may incorrectly pass the assertion even if the `value` is greater than `max_supply`, because the function does not verify that `value >= 0`. The second function, however, asserts that `0 <= value <= max_supply`, which will correctly prevent an incorrect `value` from passing the assertion.

```cairo
@storage_var
func max_supply() -> (res: felt) {
}

@external
func bad_comparison{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}() {
    let (value: felt) = ERC20.total_supply();
    assert_le{range_check_ptr=range_check_ptr}(value, max_supply.read());

    // do something...

    return ();
}

@external
func better_comparison{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}() {
    let (value: felt) = ERC20.total_supply();
    assert_nn_le{range_check_ptr=range_check_ptr}(value, max_supply.read());

    // do something...

    return ();

}
```

# Mitigations

- Carefully review all felt comparisons.
- Determine the desired behavior of the comparison and decide if `assert_nn_le` or `assert_le_felt` is more appropriate.
- Use `assert_le` if you explicitly want to compare signed integers. Otherwise, clearly document why it is used over `assert_nn_le`.
