# Irreversible State Changes in Multi-Contract Flows

Multi-contract message cascades on TON lack atomic rollback, leaving state permanently inconsistent on failure.

## Description

TON smart contracts communicate asynchronously via messages. Complex operations often span multiple contracts in a message cascade: contract A sends to B, B sends to C, and C sends back to A. Each contract updates its own state upon receiving a message. If any step in the cascade fails (e.g., due to insufficient gas, a thrown exception, or an out-of-gas error), the state changes made in earlier steps are not automatically rolled back. Unlike EVM transactions, there is no atomic transaction boundary across multiple TON contracts.

This means a multi-step operation can leave the system in an inconsistent state. A common pattern is a "lock-then-execute" flow: contract A increments a lock counter to prevent concurrent operations, sends a message to contract B for processing, and expects a response to decrement the lock. If contract B fails, the lock is never released, and the user's funds become permanently inaccessible.

## Exploit Scenario

Alice deploys a DEX consisting of a user contract and a pool contract. When a user initiates a swap, the user contract increments a state lock and forwards the request to the pool contract. Bob calls the swap function with just enough gas for the user contract but insufficient gas for the pool contract. The user contract increments its state lock to 1 and sends the swap message to the pool. The pool contract runs out of gas and fails. The completion message is never sent back to the user contract, so the state lock is never decremented. Bob's user contract is now permanently locked with `state = 1`, and all subsequent withdrawal attempts are rejected.

## Example

The following simplified code shows a DEX where the user contract increments a state counter when a swap begins. If the pool contract fails to complete the swap (e.g., runs out of gas), the user contract never receives the completion message and remains permanently locked.

```FunC
;; User contract — receives swap request and locks state
() handle_swap_request(slice in_msg_body) impure {
    (int code_version, slice pool_address, slice owner_address,
     cell user_balances, int state, cell user_rewards,
     cell backup_cell_1, cell backup_cell_2) = load_data();

    ;; Lock the user contract by incrementing state
    save_data(
        code_version, pool_address, owner_address,
        user_balances,
        state + 1,    ;; State incremented — withdrawals now blocked
        user_rewards, backup_cell_1, backup_cell_2
    );

    ;; Forward to pool for processing
    send_raw_message(build_pool_message(in_msg_body), 64);
    ;; If pool fails, state is never decremented back
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
