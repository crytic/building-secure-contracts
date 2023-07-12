# Access Controls and Account Abstraction

_NOTE: The following was possible before StarkNet OS enforced the use of an account contract._

StarkNet employs an account abstraction model, which has some key distinctions compared to what Solidity developers may be accustomed to. In StarkNet, only contract addresses exist, and there are no EOA (Externally Owned Account) addresses. Typically, users deploy a contract that authenticates them and makes additional calls on their behalf, rather than interacting with contracts directly. The most basic form of this contract verifies whether the transaction is signed by the expected key, but it can also represent more elaborate structures like multisig or DAOs, or include complex logic for transaction allowances (e.g. separate contracts for deposits and withdrawals or prevention of unprofitable trades).

Although direct contract interaction is still possible, the calling contract address will be set to 0 from the perspective of the contract being called. Since 0 is also the default value for uninitialized storage, it is possible to accidentally create access control checks that default to open access, as opposed to properly restricting access to intended users only.

## Example

Consider the two functions below, which both permit a user to claim a small number of tokens. The first function, without any checks, inadvertently sends tokens to the zero address, effectively eliminating them from the circulating supply. The second function prevents this from happening.

```Cairo
@external
func bad_claim_tokens { syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr } ():
    let (user) = get_caller_address()

    let (user_current_balance) = user_balances.read(sender_address)
    user_balances.write(user_current_balance + 200)

    return ()
end

@external
func better_claim_tokens { syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr } ():
    let (user) = get_caller_address()
    assert_not_equal(user, 0)

    let (user_current_balance) = user_balances.read(sender_address)
    user_balances.write(user, user_current_balance + 200)

    return ()
end
```

## Mitigations

- Include checks for the zero address. This will, however, prevent users from directly interacting with the contract.

## External Examples

- An [issue](https://github.com/OpenZeppelin/cairo-contracts/issues/148) found in the ERC721 implementation within a pre-0.1.0 version of OpenZeppelin's Cairo contract library, which allowed unauthorized users to transfer tokens.
