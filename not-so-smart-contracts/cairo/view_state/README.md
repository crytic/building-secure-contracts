# State Modifications in View Functions

StarkNet uses the @view decorator to indicate that a function should not modify the state. However, this restriction is [not currently enforced by the compiler](https://www.cairo-lang.org/docs/hello_starknet/intro.html). Developers should exercise caution when creating view functions and when calling functions in other contracts, as there may be unintended consequences if they accidentally include state modifications.

## Example

Consider the following function that is declared as a `@view`. It might have originally been intended solely as a view function, but was later repurposed to fetch a nonce _and increment it in the process_ to ensure that a nonce is never repeated when creating a signature.

```cairo
@view
func bad_get_nonce{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}() -> (
    nonce: felt
) {
    let (user) = get_caller_address();
    let (nonce) = user_nonces.read(user);
    user_nonces.write(user, nonce + 1);

    return (nonce);
}
```

## Mitigations

- Thoroughly review all `@view` functions, including those in third-party contracts, to make sure they don't unintentionally modify the state.

## External Examples
