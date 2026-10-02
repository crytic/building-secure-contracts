# Integer Truncation

`as` casts between integer types silently truncate or reinterpret values, even when `overflow-checks` is enabled.

## Description

Rust's `overflow-checks` setting makes `+`, `-`, and `*` panic on overflow instead of wrapping. Soroban projects enable it in the release profile, and recent versions of `stellar contract build` refuse to build a contract without it. However, `overflow-checks` does not apply to numeric casts. `as` silently keeps the low bits of the value: `(1i128 << 64) as u64` is `0`, and `-1i128 as u64` is `u64::MAX`.

Soroban contracts often mix integer types: token amounts are `i128`, while shares, prices, or ledger numbers may be stored as `u64` or `u32`. When a check is done on the cast value but the original value is used afterwards (or the other way around), the two disagree.

If a contract is built without `overflow-checks` (for example, by a custom build pipeline), arithmetic operators wrap as well.

## Exploit Scenario

Alice deploys a staking contract that tracks shares as `u64` and pays out `i128` token balances. `unstake` checks and deducts `amount as u64` shares, but credits the full `amount` in tokens. Bob owns 10 shares and calls `unstake(bob, 2^64)`. Because `2^64 as u64` is `0`, the share check passes, no shares are deducted, and Bob is credited `2^64` tokens.

## Example

```rust
#[contractimpl]
impl Staking {
    pub fn unstake(env: Env, user: Address, amount: i128) {
        user.require_auth();
        if amount <= 0 {
            panic!("invalid amount");
        }
        let shares_key = DataKey::Shares(user.clone());
        let shares: u64 = env.storage().persistent().get(&shares_key).unwrap_or(0);
        // BUG: `amount as u64` truncates, but the full `amount` is paid out
        if shares < amount as u64 {
            panic!("insufficient shares");
        }
        env.storage().persistent().set(&shares_key, &(shares - amount as u64));

        let balance_key = DataKey::Balance(user);
        let balance: i128 = env.storage().persistent().get(&balance_key).unwrap_or(0);
        env.storage().persistent().set(&balance_key, &(balance + amount));
    }
}
```

## Mitigations

- Convert between integer types with `try_from` or `try_into`, which fail when the value does not fit:

```rust
let amount_shares: u64 = amount.try_into().expect("amount out of range");
let new_shares = shares.checked_sub(amount_shares).expect("insufficient shares");
```

- Keep `overflow-checks = true` in the release profile, or use `checked_*` arithmetic, so that overflows panic instead of wrapping.
- Store related quantities in the same integer type to avoid conversions.
