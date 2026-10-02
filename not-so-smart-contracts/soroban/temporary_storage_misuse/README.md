# Temporary Storage Misuse

Security-critical state kept in `temporary` storage disappears when its TTL expires, and the contract reads it as never having been set.

## Description

Every Soroban contract data entry has a time to live (TTL), measured in ledgers. What happens when the TTL runs out depends on the storage type:

- `persistent()` and `instance()` entries are archived. Their data is kept and must be restored before it can be used again (since Protocol 23, restoration happens automatically when the transaction includes the entry in its restore footprint). A contract never sees an archived persistent entry as missing.
- `temporary()` entries are permanently deleted. Afterwards, `has()` returns `false` and `get()` returns `None`, exactly as if the entry had never been written, and the key can be written again.

Temporary storage is cheaper, so it is tempting to use it for flags such as "already claimed", "nonce used", or "signature consumed". Once the entry expires, the check that relied on it passes again. Anyone can wait for the expiration, so the attacker does not need to do anything to make it happen.

## Exploit Scenario

Alice deploys an airdrop that records each claim with a `Claimed(user)` flag in temporary storage. Bob claims his reward, waits until the flag's TTL expires, and claims again. He repeats this until the airdrop is empty.

## Example

```rust
#[contractimpl]
impl Airdrop {
    pub fn claim(env: Env, user: Address) {
        user.require_auth();
        let claimed_key = DataKey::Claimed(user.clone());
        // BUG: the flag is deleted when its TTL expires
        if env.storage().temporary().has(&claimed_key) {
            panic!("already claimed");
        }
        env.storage().temporary().set(&claimed_key, &true);

        let balance_key = DataKey::Balance(user);
        let balance: i128 = env.storage().persistent().get(&balance_key).unwrap_or(0);
        env.storage().persistent().set(&balance_key, &(balance + REWARD));
    }
}
```

## Mitigations

- Store state whose absence would weaken a security check in `persistent()` storage, and extend its TTL when it is written or read:

```rust
if env.storage().persistent().has(&claimed_key) {
    panic!("already claimed");
}
env.storage().persistent().set(&claimed_key, &true);
env.storage().persistent().extend_ttl(&claimed_key, TTL_THRESHOLD, TTL_EXTEND_TO);
```

- Use temporary storage only for data that is meaningless after a known ledger, and make sure the entry lives at least as long as that data is valid. For example, an allowance with an expiration ledger can be stored in temporary storage only if its TTL is extended to that expiration ledger.
- Extend the TTL of persistent and instance entries that users depend on, so that they do not have to pay to restore archived state.

## References

- [Stellar docs: State archival](https://developers.stellar.org/docs/learn/fundamentals/contract-development/storage/state-archival)
