# Single-Step Ownership Transfer

Many TON smart contracts implement admin or owner role management using a single-step process: the current admin sends a message with the new admin's address, and the contract immediately updates its storage. If the admin provides an incorrect address (a typo, a wrong workchain, or a non-existent contract), access to all privileged functions is permanently lost. Unlike EVM contracts where transactions can be simulated before sending, TON's asynchronous message model makes it harder to preview the effect of administrative operations before they execute.

This pattern affects any irrevocable operation performed in a single step, including ownership transfers, controller changes, and critical parameter updates.

## Example

The following simplified code shows a `change_admin` operation that immediately overwrites the admin address with no confirmation step.

```FunC
() recv_internal(int my_balance, int msg_value, cell in_msg_full, slice in_msg_body) impure {
    slice cs = in_msg_full.begin_parse();
    int flags = cs~load_uint(4);
    slice sender_address = cs~load_msg_addr();

    (int op, int query_id) = (in_msg_body~load_uint(32), in_msg_body~load_uint(64));

    if (op == op::change_admin) {
        check_sender_is_admin(sender_address);
        slice new_admin = in_msg_body~load_msg_addr();
        storage::admin_address = new_admin;  ;; Immediate, irreversible change
        save_data();
        throw(0);
    }

    ;; ... rest of contract logic ...
}
```

If the admin accidentally enters the wrong address, all administrative functions (including contract upgrades, parameter changes, and emergency operations) become permanently inaccessible.

## Mitigations

- Implement a two-step transfer process: the current admin proposes a new admin, and the new admin must accept the role by sending a confirmation message from the proposed address.
- Store the proposed admin address separately from the active admin address, and only overwrite the active admin upon confirmation.
- Validate that the new address is in the correct workchain using `force_chain` or equivalent checks.
- Identify and document all irrevocable operations that privileged accounts can perform, along with their associated risks.
