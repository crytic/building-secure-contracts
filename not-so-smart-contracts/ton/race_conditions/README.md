# Race Conditions in Asynchronous Messaging

TON smart contracts process messages asynchronously. A message cascade (A sends to B, B sends to C, C sends back to A) can span multiple blocks. While one message flow is in progress, an attacker can initiate a second, independent message flow that modifies the same contract state. Properties that were validated at the start of the first flow (e.g., a user's balance, a contract's authorization status, or a dictionary entry) may no longer hold when a later message in the same flow arrives.

This is fundamentally different from EVM, where a transaction executes atomically. In TON, any assumption about state consistency across multiple messages is potentially unsafe. A common instance is bounce-handling race conditions: if a contract sends a message, receives an unrelated deposit before the bounce arrives, and then processes the bounce by restoring the original balance, the deposit is overwritten and lost.

## Example

The following simplified code shows an executor contract that tracks vault balances. A race condition between a withdrawal bounce and a concurrent deposit causes the deposit to be silently overwritten.

```FunC
;; Executor item — handles vault balance tracking
() recv_internal(int my_balance, int msg_value, cell in_msg_full, slice in_msg_body) impure {
    slice cs = in_msg_full.begin_parse();
    int flags = cs~load_uint(4);
    slice sender_address = cs~load_msg_addr();

    if (is_bounced?(flags)) {
        in_msg_body~skip_bits(32);  ;; skip bounce op prefix
        int op = in_msg_body~load_uint(32);

        if (op == op::withdraw_amount) {
            int amount = in_msg_body~load_coins();
            int hash = slice_hash(sender_address);
            ;; Overwrites current balance with bounced amount
            ;; Any deposit received between send and bounce is lost
            ctx::balances_dict~udict_replace_builder?(
                256, hash,
                begin_cell().store_coins(amount)
            );
            save_data();
        }
        return ();
    }

    ;; ... normal operations including deposits that update balances_dict ...
}
```

The race condition occurs in this sequence:
1. Executor has balance 100 for Vault A. It sends a withdrawal message.
2. Executor sets balance to 0 (withdrawal pending).
3. Vault A sends a deposit of 10 to the Executor. Executor updates balance to 10.
4. The withdrawal bounces. Executor restores balance to 100, overwriting the deposit.
5. Expected balance: 110. Actual balance: 100. The 10 from step 3 is lost.

## Mitigations

- When handling bounced messages, add the bounced amount to the current balance rather than overwriting it: `new_balance = current_balance + bounced_amount`.
- Do not assume that contract state is unchanged between sending a message and receiving a response or bounce.
- Design state updates to be additive and commutative where possible, so that concurrent operations produce correct results regardless of message ordering.
- Test multi-contract flows with interleaved operations to verify that concurrent message processing does not corrupt state.
