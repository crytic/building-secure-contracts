# Dangerous Public Imports in Libraries
NOTE: The following was possible until cairo-lang 0.10.0.

When a library is imported in Cairo, all functions can be called even if some of them are not declared in the import statement. As a result, it is possible to call functions that a developer may think is unexposed, leading to unexpected behavior.

# Example

Consider the library `library.cairo`. Even though the `example.cairo` file imports only the `check_owner()` and the `do_something()` function, the `bypass_owner_do_something()` function is still exposed and can thus be called, making it possible to circumvent the owner check.

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

Make sure to exercise caution when declaring external functions in a library. Recognize the possible state changes that can be made through the function and verify it is acceptable for anyone to call it. In addition, [Amarna](https://github.com/crytic/amarna) has a detector to uncover this issue. 


