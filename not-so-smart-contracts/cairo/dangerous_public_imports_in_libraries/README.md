# Dangerous Public Imports in Libraries

NOTE: The following issue was present until cairo-lang 0.10.0.

When a library is imported in Cairo, all functions become callable even if they are not explicitly declared in the import statement. Consequently, developers may unintentionally expose functions that lead to unexpected behavior.

# Example

Consider the library `library.cairo`. Although the `example.cairo` file imports only the `check_owner()` and `do_something()` functions, the `bypass_owner_do_something()` function is still exposed and can be called, allowing the owner check to be circumvented.

```cairo
# library.cairo

%lang starknet
from starkware.cairo.common.cairo_builtins import HashBuiltin
@storage_var
func owner() -> (res: felt):
end

func check_owner{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr: felt*}():
    let caller = get_caller_address()
    let owner = owner.read()
    assert caller = owner
    return ()
end

func do_something():
    # do something potentially dangerous that only the owner can do
    return ()
end

# for testing purposes only
@external
func bypass_owner_do_something():
    do_something()
    return ()
end

# example.cairo
%lang starknet
%builtins pedersen range_check
from starkware.cairo.common.cairo_builtins import HashBuiltin
from library import check_owner(), do_something()
# Even though we just import check_owner() and do_something(), we can still call bypass_owner_do_something()!
func check_owner_and_do_something{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr: felt*}():
    check_owner()
    do_something()
    return ()
end
```

# Mitigations

Exercise caution when declaring external functions in a library. Evaluate the potential state changes that can be made through the function and ensure it is safe for any user to call. Additionally, [Amarna](https://github.com/crytic/amarna) includes a detector to help identify this issue.
