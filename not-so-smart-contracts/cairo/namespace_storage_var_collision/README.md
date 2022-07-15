# Namespace Storage Variable Collsion

In Cairo, it is possible to use namespaces to scope functions under an identifier. However, storage variables are not scoped by these namespaces. If a developer accidentally uses the same variable name in two different namespaces, it could lead to a storage collision.

# Example 

The following example has been copied from [here](https://gist.github.com/koloz193/18cb491167e844e9a28ac69825f68975). Suppose we have two different namespaces `A` and `B`, both with the same `balance` storage variable. In addition, both namespaces have respective functions `increase_balance()` and `get_balance()` to increment the storage variable and retrieve it respectively. When either `increase_balance_a` or `increase_balance_b()` is called, the expected behavior would be to have two seperate storage variables have their balance increased respectively. However, because storage variables are not scoped by namespaces, there will be one `balance` variable updated twice: 

```cairo
%lang starknet

from starkware.cairo.common.cairo_builtins import HashBuiltin

from openzeppelin.a import A
from openzeppelin.b import B

@external
func increase_balance_a{
        syscall_ptr : felt*, pedersen_ptr : HashBuiltin*,
        range_check_ptr}(amount : felt):
    A.increase_balance(amount)
    return ()
end

@external
func increase_balance_b{
        syscall_ptr : felt*, pedersen_ptr : HashBuiltin*,
        range_check_ptr}(amount : felt):
    B.increase_balance(amount)
    return ()
end

@view
func get_balance_a{
        syscall_ptr : felt*, pedersen_ptr : HashBuiltin*,
        range_check_ptr}() -> (res : felt):
    let (res) = A.get_balance()
    return (res)
end

@view
func get_balance_b{
        syscall_ptr : felt*, pedersen_ptr : HashBuiltin*,
        range_check_ptr}() -> (res : felt):
    let (res) = B.get_balance()
    return (res)
end
```

# Mitigations

Make sure to not use the same storage variable name in the namespace (or change the return value's name, see [here](https://github.com/crytic/amarna/issues/10)). Also use [Amarna](https://github.com/crytic/amarna) to uncover this issue, since it has a detector for storage variable collisions.
