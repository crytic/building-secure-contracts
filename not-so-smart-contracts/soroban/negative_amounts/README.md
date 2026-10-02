# Negative Amounts

Token amounts in Soroban are signed `i128` values, so a missing non-negative check lets attackers reverse the direction of transfers.

## Description

The Soroban token interface ([SEP-41](https://github.com/stellar/stellar-protocol/blob/master/ecosystem/sep-0041.md)), including the Stellar Asset Contract, represents amounts as `i128`. A balance check such as `from_balance < amount` passes for any negative amount, and the arithmetic that follows moves funds in the opposite direction: `from_balance - amount` increases the sender's balance and `to_balance + amount` decreases the recipient's.

The same issue affects every function that takes an amount, including deposits, withdrawals, swaps, mints, and burns.

## Exploit Scenario

Alice deploys a token whose `transfer` function requires the sender's authorization and checks that the sender's balance is at least `amount`, but does not reject negative amounts. Bob, who owns nothing, calls `transfer(bob, alice, -1000)` and authorizes it with his own key. The balance check passes (`0 < -1000` is false), Bob's balance becomes `1000`, and Alice's balance decreases by `1000`.

## Example

```rust
#[contractimpl]
impl Token {
    pub fn transfer(env: Env, from: Address, to: Address, amount: i128) {
        from.require_auth();
        // BUG: `amount` may be negative
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

- Reject negative amounts at the start of every function that takes an amount (and zero amounts where they make no sense):

```rust
if amount < 0 {
    panic!("negative amount");
}
```

- Do not assume that a token contract performs this check for you; a malicious or buggy token may accept negative values.
