# Mutable Reference Shadowing

Destructured `mut` bindings in Sui Move silently rebind local variables instead of writing through to struct fields.

## Description

In Sui Move, destructuring a mutable reference with `mut` creates a local mutable binding rather than a mutable borrow of the underlying field. Assigning to this binding (e.g., `left = limit`) only reassigns the local variable -- it does not write through the reference to update the struct field. To actually modify the field, the developer must dereference explicitly with `*left = *limit`. This is a subtle quirk of Move's ownership and reference system.

Unlike Rust, which would emit a compiler warning about the unused write, Move silently accepts the reassignment. The practical result is that state updates appear correct in source code but silently fail to persist, leaving on-chain data unchanged after a transaction that was supposed to mutate it.

## Exploit Scenario

Alice deploys a minting module with a `MinterCap` shared object that tracks how many tokens remain mintable per epoch. When a new epoch starts, the `mint` function is supposed to reset the remaining allowance by assigning `left = limit`. Bob notices the destructured `mut left` binding only rebinds the local variable. Bob waits until the epoch rolls over and then calls `mint` repeatedly. Because the allowance was never actually reset on-chain, all minting attempts after the first epoch's supply is exhausted permanently fail, denying service to all users.

## Example

A minting module tracks how many tokens can still be minted in the current epoch. When a new epoch begins, the remaining allowance should reset to the configured limit. The destructuring below introduces a local `left` binding that shadows the reference to the actual field.

```move
public fun mint(cap: &mut MinterCap, ctx: &mut TxContext) {
    let MinterCap { limit, epoch, mut left } = cap;

    // If the epoch has rolled over, reset the remaining allowance
    if (tx_context::epoch(ctx) > *epoch) {
        *epoch = tx_context::epoch(ctx);
        // BUG: reassigns the local variable, not the struct field
        left = limit;
    };

    assert!(*left > 0, EMintExhausted);
    *left = *left - 1;
}
```

The assignment `left = limit` only points the local `left` at the same value as `limit`. The `MinterCap.left` field on-chain is never updated, so the minting allowance is never actually reset.

The fix is to dereference both sides of the assignment:

```move
*left = *limit;
```

## Mitigations

- Always dereference when writing through struct field references (`*field = value`); a plain assignment only rebinds the local variable.
- Add integration tests that verify on-chain state actually changes after functions that are supposed to mutate it.
- Include `mut` destructuring patterns in code-review checklists, specifically checking that every assignment to a destructured binding uses the `*` dereference operator.
- Prefer direct field assignment on the struct reference (e.g., `cap.left = cap.limit`) where the Move version supports it, as this avoids the shadowing problem entirely.
