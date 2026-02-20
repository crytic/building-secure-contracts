# Runtime Limit Denial of Service

Sui's hard runtime limits on shared objects allow attackers to permanently brick shared state with crafted input.

## Description

Sui enforces several hard runtime limits that, when exceeded, abort the entire transaction. Because shared objects persist across transactions, malicious data that triggers these limits can permanently brick shared state. An attacker only needs to push a shared object past a single limit once -- every future transaction that touches that object will also abort, locking out all users.

The key limits are: dynamic field accesses (1,000 per transaction), maximum object size (256,000 bytes), computation budget (`max_computation_budget`), and event processing (50 per checkpoint). Each can be weaponized when user-controlled input determines how much work a transaction performs or how large an object grows. The common thread is an asymmetry: the attacker's setup cost is O(1) or very cheap, while the resulting damage forces O(n) costs on every other user.

## Exploit Scenario

Alice deploys a vault contract that distributes rewards to all participants by iterating over a dynamic field table. Each user requires two dynamic field accesses per iteration. Bob creates 501 accounts and joins the vault with each one. When Alice or any user calls `distribute_funds`, the function attempts over 1,000 dynamic field accesses, exceeding Sui's per-transaction limit. The transaction aborts, and because the shared vault object retains all 501 entries, every future call to `distribute_funds` also aborts, permanently locking all deposited funds.

## Example

A vault distributes funds to all participants by iterating over a dynamic field table. Each user requires two dynamic field accesses (one to read the balance, one to write the updated balance). An attacker joins the vault with enough accounts to push the total past 501 users, causing every call to `distribute_funds` to exceed the 1,000 dynamic field access limit and abort.

```move
public fun distribute_funds(vault: &mut Vault, amount: u64) {
    let total_users = vault.user_count;
    let per_user = amount / total_users;
    let i = 0;
    while (i < total_users) {
        // Two dynamic field accesses per iteration:
        let balance = dynamic_field::borrow_mut<u64, u64>(&mut vault.id, i);
        *balance = *balance + per_user;
        i = i + 1;
    };
}
```

A separate class of attack targets the 256KB object size limit. A shared registry stores participant metadata including user-controlled string fields. A malicious user sets `display_name` and `bio` to very long byte strings, bloating the shared `Registry` object past the size cap and blocking all subsequent writes, including withdrawals.

```move
public fun register_participant(
    registry: &mut Registry,
    display_name: String,
    bio: String,
    ctx: &mut TxContext,
) {
    // An attacker sets display_name and bio to ~256KB each,
    // pushing the Registry object past the 256,000-byte limit.
    let participant = ParticipantInfo {
        id: object::new(ctx),
        display_name,
        bio,
        deposit: 0,
    };
    vector::push_back(&mut registry.participants, participant);
}
```

## Mitigations

- Use pull-based (claim) patterns instead of push-based iteration over shared objects so that each user's transaction only touches their own data.
- Paginate batch operations with a cursor or index parameter so no single transaction iterates the full collection.
- Cap the byte length of all user-controlled string fields before storing them in shared objects.
- Configure data structure parameters (e.g., `max_slice_size` in BigVector) well below the 256KB object size limit to prevent individual nodes from exceeding it.
- Enforce minimum deposit or stake amounts to make it expensive for an attacker to create many entries.
- Test every shared-object function with the maximum expected data size to verify it stays within runtime limits.
- Treat any O(n) loop over a shared object as a potential DoS vector during security review.
