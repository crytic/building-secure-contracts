# Missing Object Uniqueness Enforcement

Sui's object model lacks built-in one-per-address constraints, allowing duplicate singleton objects to bypass restrictions.

## Description

In Sui, every call to `object::new(ctx)` creates a new object with a unique UID, and `transfer::transfer` sends it to an address in a one-way operation with no built-in deduplication. Unlike the EVM, where writing to a `mapping(address => Struct)` naturally enforces one entry per address, Sui has no `mapping`-equivalent that ties a single value to each address at the storage layer. Once an object is transferred, the contract cannot enumerate which objects an address already owns -- there is no on-chain index of objects by type and owner accessible from Move code.

This architectural gap means that if a registration function creates and transfers a new object without explicitly checking a separate registry, users can accumulate duplicate objects. A user holding two `Membership` objects can have `is_active = true` on one and `is_active = false` on the other, allowing them to bypass single-use restrictions by switching to the unconsumed copy. The same class of bug applies to any system that assumes one-object-per-user semantics -- profiles, accounts, memberships, or any singleton-like abstraction built on transferred objects.

## Exploit Scenario

Alice deploys a membership module where an admin registers members by creating a `Membership` object and calling `transfer::transfer` to send it to the member's address. Bob convinces the admin to register his address twice (or exploits a public registration function). Bob now owns two `Membership` objects. When the protocol deactivates Bob's first membership by setting `is_active = false`, Bob simply passes his second `Membership` object to bypass the restriction, breaking the single-membership invariant the protocol depends on.

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

## Mitigations

- Track registered entities in a `Table<address, ID>` or `ObjectTable` keyed by address and assert the key does not exist before creating a new object.
- Consider using dynamic fields on a shared registry object instead of transferring individual objects, making uniqueness structurally enforced by the key.
- Write tests that attempt duplicate registration and confirm the transaction aborts.
- Audit every function that calls `object::new` followed by `transfer::transfer` for missing uniqueness checks.
