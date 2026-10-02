# Missing Authorization

Privileged functions that never call `require_auth` let anyone act on behalf of any address.

## Description

Soroban has no implicit `msg.sender`. A contract learns who approved an invocation only by calling `Address::require_auth()` (or `require_auth_for_args()`) on the address whose permission is needed. The host then checks the signatures (or the invoking contract) for that address and handles nonces and signature expiration to prevent replays.

If a function moves funds, changes ownership, or updates configuration on behalf of an `Address` argument without calling `require_auth` on that address, the address is just a value chosen by the caller. Anyone can submit a transaction that names someone else's address.

## Exploit Scenario

Alice deploys a token whose `transfer` function debits the `from` address but never calls `from.require_auth()`. Bob calls `transfer(alice, bob, 1000)` without any signature from Alice and receives her entire balance.

## Example

```rust
#[contractimpl]
impl Token {
    pub fn transfer(env: Env, from: Address, to: Address, amount: i128) {
        // BUG: `from` never authorizes this transfer
        if amount <= 0 {
            panic!("invalid amount");
        }
        let from_balance: i128 = env.storage().persistent().get(&DataKey::Balance(from.clone())).unwrap_or(0);
        if from_balance < amount {
            panic!("insufficient balance");
        }
        let to_balance: i128 = env.storage().persistent().get(&DataKey::Balance(to.clone())).unwrap_or(0);
        env.storage().persistent().set(&DataKey::Balance(from), &(from_balance - amount));
        env.storage().persistent().set(&DataKey::Balance(to), &(to_balance + amount));
    }
}
```

## Mitigations

- Call `require_auth()` on every address whose funds, permissions, or settings a function changes, before using it:

```rust
pub fn transfer(env: Env, from: Address, to: Address, amount: i128) {
    from.require_auth();
    // ...
}
```

- Call `require_auth` in the entry point a user invokes, not only in an inner contract call. An authorized inner call that is not wrapped by an entry point requiring the same authorization can be front-run by anyone.
- In unit tests, avoid relying only on `env.mock_all_auths()`. Use `env.mock_auths()` with the exact signers, or assert on `env.auths()`, so that a missing `require_auth` makes a test fail.
- Consider using [Scout](https://github.com/CoinFabrik/scout-soroban), which includes detectors for unprotected storage writes and transfers.

## References

- [Stellar docs: Authorization](https://developers.stellar.org/docs/learn/fundamentals/contract-development/authorization)
