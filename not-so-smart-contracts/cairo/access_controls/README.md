# Access controls & account abstraction

The account abstraction model used by StarkNet has some important differences from what Solidity developers might be used to. There are no EOA addresses in StarkNet, only contract addresses. Rather than interact with contracts directly, users will usually deploy a contract that authenticates them and makes further calls on the user's behalf. In the most simple case, this contract checks that the transaction is signed by the expected key, but it could also represent a multisig or DAO, or have more complex logic for what kinds of transactions it will allow (e.g. deposits and withdrawals could be handled by separate contracts or it could prevent unprofitable trades). Depending on the type of call, access controll should be implemented with different approaches:

* It is still possible to interact with contracts directly (e.g. without using an account). From the perspective of the contract, the caller's address will be 0x0. Since 0x0 is also the default value for uninitialized storage, it's possible to accidentally construct access control checks that fail open instead of properly restricting access to only the intended users.

* If a contract is called from L1, the access control should be only implemented using the caller address parameters and not `get_caller_address()` function, which will return 0x0.

## Example

Consider the following two functions that both allow a user to claim a small amount of tokens. The first, without any checks, will end up sending tokens to the zero address, effectively burning them by removing them from the circlating supply. The latter will ensure that this cannot happen.

```cairo
@external
func bad_claim_tokens{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}():
    let (user) = get_caller_address()

    let (user_current_balance) = user_balances.read(sender_address)
    user_balances.write(user_current_balance + 200)

    return ()
end

@external
func better_claim_tokens{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}():
    let (user) = get_caller_address()
    assert_not_equal(user,0)

    let (user_current_balance) = user_balances.read(sender_address)
    user_balances.write(user, user_current_balance + 200)

    return ()
end
```

## Mitigations

- Add zero address checks. Note that this will prevent users from interacting with the contract directly.
- Do not use `get_caller_address()` in functions that are supposed to be called from L1.
- If a contract has a function that should be called from L1 contract, [the `@l1_handler` should be used](https://starknet.io/docs/hello_starknet/l1l2.html#receiving-a-message-from-l1). This forces the first parameter of such function to be the address of the contract or EOA that performed the cross-chain call.

## External Examples

- An [issue](https://github.com/OpenZeppelin/cairo-contracts/issues/148) in the ERC721 implementation included in a pre-0.1.0 version of OpenZeppelin's Cairo contract library would have allowed unapproved users to transfer tokens.
