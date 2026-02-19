# Silent Message Failure

TON provides the `SendIgnoreErrors` (mode 2) flag for sending messages. When this flag is used, if the contract's current balance is insufficient to cover the message value, the message is silently dropped during the action phase — no error is raised and no bounce message is generated. The sending contract's state has already been updated in the compute phase, so any accounting changes (balance decrements, state transitions) persist even though the message was never delivered.

This creates a class of vulnerabilities where funds appear to have been sent but never arrive at the destination. The sender's internal accounting shows a completed transfer, but the recipient's balance is unchanged. Over time, this leads to state desynchronization between contracts and unrecoverable fund loss.

## Example

The following simplified code shows a token sending utility that uses `SendIgnoreErrors`. If the contract's TON balance is insufficient, the Jetton transfer message is silently dropped and the user loses their funds.

```FunC
;; Message utility — all sends use SendIgnoreErrors
() send_tokens(slice to_address, int token_amount, int gas_amount) impure {
    cell msg = begin_cell()
        .store_uint(0x18, 6)
        .store_slice(to_address)
        .store_coins(gas_amount)
        .store_uint(0, 107)
        .store_uint(op::transfer, 32)
        .store_uint(0, 64)
        .store_coins(token_amount)
        .end_cell();

    ;; If contract balance < gas_amount, message is silently dropped
    send_raw_message(msg, 2);  ;; SendIgnoreErrors
}

;; Settlement contract — processes withdrawal
() handle_withdrawal(slice in_msg_body) impure {
    (slice user, int amount) = parse_withdrawal(in_msg_body);

    ;; User's balance already decremented
    update_user_balance(user, -amount);
    save_data();

    ;; If this message is dropped, user loses funds
    send_tokens(user, amount, 50000000);
}
```

## Mitigations

- Verify that the contract's balance is sufficient to cover the message value before sending. If insufficient, revert the state changes or notify the sender via a bounce message.
- Avoid using `SendIgnoreErrors` for messages that transfer value or trigger critical state changes. Use mode 0 or mode 1 instead, which will cause the transaction to fail if the message cannot be sent.
- Implement balance checks before all TON transfers: `throw_unless(error::insufficient_balance, my_balance > required_amount)`.
- Add tests that verify system behavior when contract balances are low, ensuring that no silent message drops can occur during normal operation.
