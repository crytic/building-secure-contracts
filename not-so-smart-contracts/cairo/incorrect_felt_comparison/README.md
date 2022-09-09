# Incorrect Felt Comparison

In Cairo, there are two builtin methods for the less than or equal to comparison operator: `assert_le` and `assert_nn_le`. `assert_le` asserts that a number `a` is less than or equal to `b`, regardless of the size of `a`, while `assert_nn_le` additionally asserts that `a` is non-negative, i.e. not greater than or equal to the `RANGE_CHECK_BOUND` value of `2^128`: https://github.com/starkware-libs/cairo-lang/blob/master/src/starkware/cairo/common/math.cairo#L66-L67

# Example

Suppose that a codebase uses the following checks regarding a hypothetical ERC20 token. In the first function, it may be possible that `value` is in fact greater than `max_supply`, yet because the function does not verify `value >= 0` the assertion will incorrectly pass. The second function, however, asserts that `0 <= value <= max_supply`, which will correctly not let an incorrect `value` go through the assertion.

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
Review all felt comparisons closely. Determine what sort of behavior the comparison should have, and if `assert_nn_le` is more appropriate.
