# Missing Object Uniqueness Enforcement

In Sui, every call to `object::new(ctx)` creates a new object with a unique UID. Unlike the EVM's account-based storage where writing to a `mapping(address => Struct)` naturally enforces one entry per address, Sui's object model has no built-in constraint preventing multiple objects of the same type from being associated with the same address. If a registration function creates and transfers a new object without checking whether one already exists for that address, users can accumulate duplicate objects.

This leads to state inconsistency: a user holding two `Membership` objects can have `is_active = true` on one and `is_active = false` on the other, allowing them to bypass single-use restrictions by switching to the second object. The same class of bug applies to any system that assumes one-object-per-user semantics -- profiles, accounts, memberships, or any singleton-like abstraction built on transferred objects.

## Example

A module lets an admin register members. The function creates a fresh `Membership` and transfers it to the given address, but nothing prevents the admin from calling it twice for the same user:

```move
public struct Membership has key, store {
    id: UID,
    is_active: bool,
}

public fun register_member(
    _: &AdminCap,
    member_addr: address,
    ctx: &mut TxContext,
) {
    let membership = Membership {
        id: object::new(ctx),
        is_active: false,
    };
    // BUG: no check whether member_addr already has a Membership object
    transfer::transfer(membership, member_addr);
}
```

If the admin registers the same address twice, that user now owns two `Membership` objects. When the first is locked with `is_active = true`, the user simply passes the second to bypass the restriction, breaking the single-membership invariant. The fix is to maintain a registry that tracks which addresses have already been registered:

```move
public fun register_member(
    _: &AdminCap,
    registry: &mut Table<address, ID>,
    member_addr: address,
    ctx: &mut TxContext,
) {
    assert!(!table::contains(registry, member_addr), EAlreadyRegistered);
    let membership = Membership {
        id: object::new(ctx),
        is_active: false,
    };
    table::add(registry, member_addr, object::id(&membership));
    transfer::transfer(membership, member_addr);
}
```

## Mitigations

- Track registered entities in a `Table<address, ID>` or `ObjectTable` keyed by address and assert the key does not exist before creating a new object.
- Consider using dynamic fields on a shared registry object instead of transferring individual objects, making uniqueness structurally enforced by the key.
- Write tests that attempt duplicate registration and confirm the transaction aborts.
- Audit every function that calls `object::new` followed by `transfer::transfer` for missing uniqueness checks.
