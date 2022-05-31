# Access controls & account abstraction

The account abstraction model used by StarkNet has some important differences from what Solidity developers might be used to. There are no EOA addresses in StarkNet, only contract addresses. Rather than interact with contracts directly, users will usually deploy a contract that authenticates them and makes further calls on the user's behalf. At its simplest, this contract checks that the transaction is signed by the expected key, but it could also represent a multisig or DAO, or have more complex logic for what kinds of transactions it will allow (e.g. deposits and withdrawals could be handled by separate contracts or it could prevent unprofitable trades).

It is still possible to interact with contracts directly. But from the perspective of the contract, the caller's address will be 0. Since 0 is also the default value for uninitialized storage, it's possible to accidentally construct access control checks that fail open instead of properly restricting access to only the intended users.

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

## External Examples

- An [issue](https://github.com/OpenZeppelin/cairo-contracts/issues/148) in the ERC721 implementation included in a pre-0.1.0 version of OpenZeppelin's Cairo contract library would have allowed unapproved users to transfer tokens.