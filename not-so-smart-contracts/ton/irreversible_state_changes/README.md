# Irreversible State Changes in Multi-Contract Flows

TON smart contracts communicate asynchronously via messages. Complex operations often span multiple contracts in a message cascade: contract A sends to B, B sends to C, and C sends back to A. Each contract updates its own state upon receiving a message. If any step in the cascade fails (e.g., due to insufficient gas, a thrown exception, or an out-of-gas error), the state changes made in earlier steps are not automatically rolled back. Unlike EVM transactions, there is no atomic transaction boundary across multiple TON contracts.

This means a multi-step operation can leave the system in an inconsistent state. A common pattern is a "lock-then-execute" flow: contract A increments a lock counter to prevent concurrent operations, sends a message to contract B for processing, and expects a response to decrement the lock. If contract B fails, the lock is never released, and the user's funds become permanently inaccessible.

## Example

The following simplified code shows a lending protocol where the user contract increments a state counter when a liquidation begins. If the master contract fails to complete the liquidation (e.g., runs out of gas), the user contract never receives the completion message and remains permanently locked.

```FunC
;; User contract — receives liquidation request and locks state
() handle_liquidation_request(slice in_msg_body) impure {
    (int code_version, slice master_address, slice owner_address,
     cell user_principals, int state, cell user_rewards,
     cell backup_cell_1, cell backup_cell_2) = load_data();

    ;; Lock the user contract by incrementing state
    save_data(
        code_version, master_address, owner_address,
        user_principals,
        state + 1,    ;; State incremented — withdrawals now blocked
        user_rewards, backup_cell_1, backup_cell_2
    );

    ;; Forward to master for processing
    send_raw_message(build_master_message(in_msg_body), 64);
    ;; If master fails, state is never decremented back
}

;; User contract — blocks withdrawals when state > 0
() handle_withdrawal(slice in_msg_body) impure {
    (_, _, _, _, int state, _, _, _) = load_data();

    if (state != 0) {
        ;; Withdrawal blocked — contract is locked
        send_error_response(error::contract_locked);
        return ();
    }

    ;; ... process withdrawal ...
}
```

## Mitigations

- Ensure that every state-locking operation has a guaranteed unlock path, including explicit timeout-based recovery mechanisms.
- Validate that sufficient gas is available for the entire message cascade before making any state changes.
- Implement explicit error handling at each step in a multi-contract flow so that failures at any point trigger appropriate state rollbacks via response messages.
- Add administrative recovery functions that can unlock contracts stuck in an inconsistent state, protected by appropriate access controls.
- Test all failure paths in multi-contract flows, including out-of-gas conditions at each intermediate step.
