# Resource Limit Denial of Service

Storage or loops that grow with the number of users eventually exceed Soroban's per-transaction resource limits, making a function permanently unusable.

## Description

Every Soroban transaction is bounded by network-configured limits on CPU instructions, memory, the number of ledger entries read and written, the bytes read and written, and the size of each ledger entry. Exceeding any of these limits aborts the transaction. These errors cannot be caught with `try_invoke_contract`, so the caller cannot work around them.

Two patterns are common:

- Looping over a list of users (or any collection that anyone can extend) and touching one storage entry per user. Once the list is long enough, the function exceeds the ledger entry or instruction limit on every call.
- Keeping an unbounded `Vec` or `Map` under a single key, especially in `instance()` storage. Instance storage is loaded on every invocation of the contract, and a collection under one key is read and written in full on every update, so its growth makes every function more expensive until it reaches the ledger entry size limit.

Because the collection grows with user actions, an attacker can push it past the limit at the cost of a few transactions.

## Exploit Scenario

Alice deploys a rewards contract that stores every staker in a `Vec` in instance storage, and a `distribute` function that adds the reward to each staker's entry. Bob registers a few hundred addresses. `distribute` now needs more ledger entries than a transaction can access, and it fails on every call, so no staker ever receives rewards again.

## Example

```rust
#[contractimpl]
impl Rewards {
    pub fn register(env: Env, staker: Address) {
        staker.require_auth();
        // BUG: unbounded collection in instance storage
        let mut stakers: Vec<Address> = env.storage().instance().get(&DataKey::Stakers).unwrap_or(Vec::new(&env));
        stakers.push_back(staker);
        env.storage().instance().set(&DataKey::Stakers, &stakers);
    }

    pub fn distribute(env: Env, amount_each: i128) {
        let stakers: Vec<Address> = env.storage().instance().get(&DataKey::Stakers).unwrap_or(Vec::new(&env));
        // BUG: one storage write per staker
        for staker in stakers.iter() {
            let key = DataKey::Reward(staker);
            let reward: i128 = env.storage().persistent().get(&key).unwrap_or(0);
            env.storage().persistent().set(&key, &(reward + amount_each));
        }
    }
}
```

## Mitigations

- Store per-user data under per-user keys in `persistent()` storage (for example, `DataKey::Staked(address)`), not in a collection under one key, and never keep unbounded data in `instance()` storage.
- Replace loops over users with constant-cost accounting. For rewards, update a global accumulator and let each user settle their own share:

```rust
pub fn distribute(env: Env, amount_each: i128) {
    let acc: i128 = env.storage().instance().get(&DataKey::RewardPerShare).unwrap_or(0);
    env.storage().instance().set(&DataKey::RewardPerShare, &(acc + amount_each));
}
```

- If iteration cannot be avoided, bound the collection's size or process it in pages across several transactions.
- Test functions with realistic, adversarial collection sizes. The soroban-sdk test environment reports when an invocation exceeds the network's resource limits.

## References

- [Stellar docs: Resource limits and fees](https://developers.stellar.org/docs/networks/resource-limits-fees)
- [Stellar docs: Persisting data](https://developers.stellar.org/docs/learn/fundamentals/contract-development/storage/persisting-data)
