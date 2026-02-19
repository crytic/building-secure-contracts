# Type Parameter Griefing

In Sui Move, `public entry` functions with generic type parameters (e.g., `<ASSET: key + store>`) can be called by any user with any type that satisfies the ability constraints. The caller controls which concrete type is substituted at the call site. If the function performs an irreversible state change -- like popping an order from a queue -- before validating that the generic type matches the expected asset, an attacker can call the function with a wrong type. The type mismatch causes downstream logic to fail (e.g., a precheck returns `false`), but the state change has already occurred and the order is consumed without being executed.

This is Sui-specific because Move generics are resolved at the call site -- any caller can pass any qualifying type. On the EVM, function signatures are fixed and there are no generics. The practical impact is that an attacker can repeatedly invoke the function with a mismatched type to drain an entire order queue, destroying every pending order without executing any of them.

## Example

A task-processing entry function pops the next request from a shared queue and then iterates over its steps. Each step calls a validation function parameterized by the generic `ASSET` type. When the caller supplies a type that does not match the request's actual asset, every validation returns `false` and the steps are skipped -- but the request has already been removed from the queue and is permanently lost.

```move
public entry fun process_request<ASSET: key + store>(
    queue: &mut RequestQueue,
    ctx: &mut TxContext,
) {
    // Irreversible: request is removed from the queue
    let request = request_queue::pop_front(queue);

    let i = 0;
    while (i < vector::length(&request.steps)) {
        let step = vector::borrow(&request.steps, i);
        // BUG: if ASSET doesn't match the request's real asset, validation
        // returns false and the step is silently skipped
        if (validate_step<ASSET>(step)) {
            execute_step<ASSET>(step, ctx);
        };
        i = i + 1;
    };
    // request is consumed; if every validation failed, all work is lost
}
```

The fix is to validate the type before performing the irreversible pop. Abort on mismatch so the transaction reverts and the request stays in the queue:

```move
public entry fun process_request<ASSET: key + store>(
    queue: &mut RequestQueue,
    ctx: &mut TxContext,
) {
    // Validate type BEFORE mutating state
    assert!(request_queue::peek_asset_type(queue) == type_name::get<ASSET>(), ETypeMismatch);

    let request = request_queue::pop_front(queue);
    // ... execute steps ...
}
```

## Mitigations

- Validate that the generic type parameter matches the expected asset type **before** any irreversible state mutations such as pops, deletions, or transfers.
- Abort on type mismatch (`assert!` with an error code) instead of returning `false` and silently skipping work, so the entire transaction reverts and no state is lost.
- Separate type validation into a guard function that runs before the destructive action, making it impossible to reach the mutation without passing the check.
- Consider using phantom type parameters or witness patterns to bind the type at object creation time, preventing arbitrary type substitution at the call site.
