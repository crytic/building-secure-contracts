# Race Conditions in Asynchronous Messaging

Concurrent message flows on TON can modify shared contract state, invalidating earlier assumptions.

## Description

TON smart contracts process messages asynchronously. A message cascade (A sends to B, B sends to C, C sends back to A) can span multiple blocks. While one message flow is in progress, an attacker can initiate a second, independent message flow that modifies the same contract state. Properties that were validated at the start of the first flow (e.g., a user's balance, a contract's authorization status, or a dictionary entry) may no longer hold when a later message in the same flow arrives.

This is fundamentally different from EVM, where a transaction executes atomically. In TON, any assumption about state consistency across multiple messages is potentially unsafe. A common instance is bounce-handling race conditions: if a contract sends a message, receives an unrelated deposit before the bounce arrives, and then processes the bounce by restoring the original balance, the deposit is overwritten and lost.

## Exploit Scenario

Alice deploys a DEX pool contract that tracks LP token balances per user in a dictionary. Bob holds 100 LP tokens and initiates a remove-liquidity operation. The pool sets Bob's LP balance to 0 and sends a bounceable message to transfer Bob's tokens. Before the transfer completes, Bob sends a second transaction adding 50 LP of new liquidity. The pool updates Bob's balance to 50. The original transfer then bounces due to an error at the destination. The pool's bounce handler overwrites Bob's balance with the original 100 LP (the bounced amount) instead of adding it. Bob's 50 LP deposit from the second transaction is silently erased. Expected balance: 150. Actual balance: 100.

## Example

The following simplified code shows a DEX pool contract that tracks user LP token balances. A race condition between a liquidity removal bounce and a concurrent deposit causes the deposit to be silently overwritten.

```FunC
;; DEX pool contract — tracks LP token balances per user
() recv_internal(int my_balance, int msg_value, cell in_msg_full, slice in_msg_body) impure {
    slice cs = in_msg_full.begin_parse();
    int flags = cs~load_uint(4);
    slice sender_address = cs~load_msg_addr();

    if (is_bounced?(flags)) {
        in_msg_body~skip_bits(32);  ;; skip bounce op prefix
        int op = in_msg_body~load_uint(32);

        if (op == op::remove_liquidity) {
            int lp_amount = in_msg_body~load_coins();
            int hash = slice_hash(sender_address);
            ;; Overwrites current LP balance with bounced amount
            ;; Any deposit received between send and bounce is lost
            ctx::lp_balances~udict_replace_builder?(
                256, hash,
                begin_cell().store_coins(lp_amount)
            );
            save_data();
        }
        return ();
    }

    ;; ... normal operations including add_liquidity that updates lp_balances ...
}
```

The race condition occurs in this sequence:
1. Pool has LP balance 100 for User A. It sends a remove-liquidity message to return tokens.
2. Pool sets User A's LP balance to 0 (removal pending).
3. User A adds liquidity of 10 to the pool. Pool updates LP balance to 10.
4. The removal bounces. Pool restores LP balance to 100, overwriting the new deposit.
5. Expected LP balance: 110. Actual LP balance: 100. The 10 LP from step 3 is lost.

## Mitigations

- When handling bounced messages, add the bounced amount to the current balance rather than overwriting it: `new_balance = current_balance + bounced_amount`.
- Do not assume that contract state is unchanged between sending a message and receiving a response or bounce.
- Design state updates to be additive and commutative where possible, so that concurrent operations produce correct results regardless of message ordering.
- Test multi-contract flows with interleaved operations to verify that concurrent message processing does not corrupt state.
