# Arithmetic Overflow Abort as Denial of Service

Sui Move aborts the entire transaction when an integer overflow occurs at runtime. Unlike pre-0.8 Solidity, which silently wraps, Move treats overflow as a fatal error. This may seem safer, but it introduces a distinct denial-of-service vector when the overflowing computation touches shared objects.

When an attacker submits crafted input (e.g., an order with a price near a type boundary) that is stored in a shared object, every subsequent transaction that reads and processes that malicious data will also trigger the overflow and abort. Because the poisoned state persists in the shared object, the object becomes permanently bricked for all users -- not just the attacker.

## Example

A token swap module multiplies two user-supplied `u64` values. An attacker submits a swap with amounts chosen so that `amount_in * price_ratio` exceeds `u64::MAX`, causing every future call that processes the swap to abort.

```move
// Vulnerable: u64 multiplication can overflow and abort, bricking the pool.
public fun process_swap(pool: &mut Pool, swap_id: u64) {
    let swap = table::borrow(&pool.pending_swaps, swap_id);
    // If amount_in is near u64::MAX / price_ratio, this aborts.
    let output: u64 = swap.amount_in * swap.price_ratio;
    let fee = (output as u256) * (swap.fee_rate as u256);
    // ... execute swap ...
}

// Fixed: cast to u128 before multiplying to avoid u64 overflow.
public fun process_swap_safe(pool: &mut Pool, swap_id: u64) {
    let swap = table::borrow(&pool.pending_swaps, swap_id);
    let output: u128 = (swap.amount_in as u128) * (swap.price_ratio as u128);
    let fee: u256 = (output as u256) * (swap.fee_rate as u256);
    // ... execute swap ...
}
```

A similar pattern appears in reward distribution. A function multiplies `user_stake * reward_multiplier` to compute a user's payout. A malicious participant registers with a `user_stake` near `u64::MAX`, causing the multiplication to overflow and aborting reward distribution for all participants.

```move
// Vulnerable: malicious user_stake aborts reward distribution.
public fun compute_reward(entry: &StakeEntry, reward_multiplier: u64): u64 {
    entry.user_stake * reward_multiplier  // aborts if user_stake is near u64::MAX
}

// Fixed: widen before multiplying.
public fun compute_reward_safe(entry: &StakeEntry, reward_multiplier: u64): u128 {
    (entry.user_stake as u128) * (reward_multiplier as u128)
}
```

## Mitigations

- Cast operands to wider types (`u128`, `u256`) before performing arithmetic on user-controlled inputs.
- Use checked multiplication helpers that return an `Option` instead of aborting, allowing graceful error handling.
- Validate input ranges at ingestion time -- reject values that could cause overflow before they are stored in shared objects.
- Test all arithmetic paths with boundary values near `u64::MAX`, `u128::MAX`, and other type limits.
- Treat any abort-on-overflow in a shared-object context as a potential DoS vector during security review.
