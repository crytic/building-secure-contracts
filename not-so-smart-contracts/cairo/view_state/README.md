# State modifications in a view function

StarkNet provides the @view decorator to signal that a function should not make state modifications. However, this is [not currently enforced by the compiler](https://starknet.io/docs/hello_starknet/intro.html). Developers should take care when designing view functions but also when calling functions in other contracts as they may result in unexpected behavior if they do include state modifications accidentally.

## Example

Consider the following function that's declared as a `@view`. It may have originally been intended as an actual view function but was later repurposed to fetch a nonce _and also increment it in the process_ to ensure a nonce is never repeated when building a signature. 

```cairo
@view
func bad_get_nonce{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}() -> (nonce : felt):
    let (user) = get_caller_address()
    let (nonce) = user_nonces.read(user)
    user_nonces.write(user, nonce + 1)

    return (nonce)
end
```

## Mitigations

- Carefully review all `@view` functions, including those called in 3rd party contracts, to ensure they don't modify state unexpectedly.

## External Examples
