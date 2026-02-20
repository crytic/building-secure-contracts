# Missing `impure` Specifier

The FunC compiler silently removes side-effecting functions lacking `impure`, eliminating security checks.

## Description

In FunC, the `impure` specifier indicates that a function has side effects — it modifies state, sends messages, or can throw exceptions. If a function that performs these actions is not marked as `impure`, the FunC compiler may optimize it away entirely when it determines that the function's return value is unused. This means critical operations such as access control checks, state validations, and error-throwing guard functions can be silently removed from the compiled contract.

This is especially dangerous for helper functions that are called solely for their side effects (e.g., `throw_unless` wrappers, permission checks). If the compiler removes such a function, the contract deploys without the intended security check, and no error or warning is produced during compilation.

## Exploit Scenario

Alice deploys a DEX contract with a `check_swap_allowed` function that verifies only the admin can initiate swaps. The function calls `throw_unless` if the sender is not the admin, but it is not marked as `impure`. The FunC compiler determines that `check_swap_allowed` returns nothing and its return value is unused, so it removes the call entirely during optimization. The deployed contract accepts swap operations from any address. Bob discovers this by inspecting the compiled bytecode and calls the swap function directly, draining liquidity from the pool without authorization.

## Example

The following simplified code shows an access control function that throws if the caller is unauthorized. Without the `impure` specifier, the compiler may remove the call entirely.

```FunC
;; Missing impure — compiler may remove this function call
() check_swap_allowed(slice sender_address) {
    (slice admin) = load_data();
    throw_unless(error::unauthorized, equal_slices(sender_address, admin));
}

;; Also missing impure — validation that throws on invalid input
() check_tick_validity(int tick_lower, int tick_upper) {
    throw_unless(error::invalid_tick, tick_lower < tick_upper);
    throw_unless(error::tick_out_of_range, tick_lower >= min_tick);
    throw_unless(error::tick_out_of_range, tick_upper <= max_tick);
}

() recv_internal(int my_balance, int msg_value, cell in_msg_full, slice in_msg_body) impure {
    slice cs = in_msg_full.begin_parse();
    int flags = cs~load_uint(4);
    slice sender_address = cs~load_msg_addr();

    (int op, int query_id) = (in_msg_body~load_uint(32), in_msg_body~load_uint(64));

    if (op == op::swap) {
        check_swap_allowed(sender_address);  ;; May be removed by compiler
        int tick_lower = in_msg_body~load_int(24);
        int tick_upper = in_msg_body~load_int(24);
        check_tick_validity(tick_lower, tick_upper);  ;; May be removed by compiler
        ;; ... execute swap without access control or validation ...
    }
}
```

## Mitigations

- Add the `impure` specifier to all functions that throw exceptions, modify contract state, or send messages.
- Thoroughly test access control and validation helper functions to verify that the compiled contract enforces them.
- When migrating from FunC to Tolk, note that Tolk does not require the `impure` specifier — all functions are treated as impure by default.
- Use integration tests that specifically test unauthorized access and invalid inputs to confirm that guard functions are not optimized away.
