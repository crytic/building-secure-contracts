# Fuzzing Tips

The following describe fuzzing tips to make Echidna more efficient:

- **To filter the values range of inputs, use `%`**. See [Filtering inputs](#filtering_inputs).

## Filtering inputs

To filter inputs, `%` is more efficient than adding `require` or `if` statements. For example, if you are a fuzzing a `f(uint256 index, ..)` where `index` is supposed to be less than `10**18`, use:

```solidity
function f(uint index, ...) public{
   index = index%10**18
}
```

If `require(index <= 10**18)` is used instead, many transactions generated will revert, slowly the fuzzer. 

This can also be used to define a min / max range, for example:


```solidity
function f(uint balance, ...) public{
   balance = `MIN_BALANCE + balance%(MAX_BALANCE - MIN_BALANCE)`
}
```

Will ensure that `balance` is always between `MIN_BALANCE` and `MAX_BALANCE`, without discarding any generated transactions.

