# Unvalidated Storage Upgrade

TON smart contracts can update their storage using `set_data`, which replaces the contract's entire persistent state with a new cell. Upgrade operations that accept a user-provided or admin-provided cell and pass it directly to `set_data` without validation can permanently brick the contract. If the new cell is malformed, incomplete, or empty, every subsequent call to the contract's `load_data` function will throw an exception, making the contract completely unusable.

This is particularly dangerous because `set_data` is irreversible in most cases — once the storage is corrupted, the contract cannot parse its own state to execute any recovery logic. The contract becomes a permanent black hole for any funds it holds.

## Example

The following simplified code shows an `upgrade_storage` operation that saves an arbitrary cell as contract storage without any validation.

```FunC
() recv_internal(int my_balance, int msg_value, cell in_msg_full, slice in_msg_body) impure {
    slice cs = in_msg_full.begin_parse();
    int flags = cs~load_uint(4);
    slice sender_address = cs~load_msg_addr();

    (int op, int query_id) = (in_msg_body~load_uint(32), in_msg_body~load_uint(64));

    if (op == op::upgrade_storage) {
        check_sender_is_admin(sender_address);
        cell new_storage = in_msg_body~load_ref();
        set_data(new_storage);   ;; No validation — any cell is accepted
        throw(0);                ;; Success exit
    }

    ;; Normal operation — will fail if storage was corrupted
    (slice admin, int balance, cell users) = load_data();
    ;; ... rest of contract logic ...
}
```

If the admin accidentally sends an empty cell or a cell with missing fields, `load_data` will throw on every subsequent call. The contract is permanently bricked, and all funds are locked.

The same issue affects upgrade processes where a new configuration variable is computed but not persisted to storage. For example, if an upgrade function generates a `new_upgrade_config` cell but fails to call `save_data`, the contract's storage remains unchanged despite the upgrade appearing to succeed.

## Mitigations

- Validate that the new storage cell can be parsed by the contract's `load_data` function before committing it with `set_data`.
- Implement a dry-run validation that attempts to parse all required fields from the new cell and throws a descriptive error if any field is missing or malformed.
- Ensure that upgrade processes persist all computed variables to storage, and verify in tests that both master and user contract code updates correctly after each upgrade.
- Consider implementing a time-locked upgrade mechanism that allows reverting within a grace period.
