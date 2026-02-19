# Missing Bounce Handler

TON smart contracts can send messages with the bounceable flag, which means the message will be returned to the sender if the destination contract fails to process it (e.g., due to an unhandled opcode, insufficient gas, or a thrown exception). If the sending contract does not implement a bounce handler, the bounced message is silently ignored. This can lead to loss of funds or inconsistent state, because the sender assumes the operation succeeded when it did not.

This issue is particularly dangerous in contracts that transfer Jettons or native TON via bounceable messages. If the transfer bounces and the sending contract has already updated its internal accounting (e.g., reduced a user's balance), the funds are effectively lost — the recipient never received them, and the sender's state reflects a completed transfer.

## Example

The following simplified code sends a Jetton transfer using a bounceable message but does not handle the bounce. If the transfer fails (e.g., the destination wallet does not exist or runs out of gas), the bounced message is silently discarded and the user's withdrawal is lost.

```FunC
#include "imports/stdlib.fc";

() send_jettons(slice to_address, int amount, slice jetton_wallet) impure {
    cell msg = begin_cell()
        .store_uint(0x18, 6)       ;; bounceable message
        .store_slice(jetton_wallet)
        .store_coins(50000000)
        .store_uint(0, 107)
        .store_uint(op::transfer, 32)
        .store_uint(0, 64)         ;; query_id
        .store_coins(amount)
        .store_slice(to_address)
        .store_uint(0, 2)          ;; empty response destination
        .store_uint(0, 1)          ;; no custom payload
        .store_coins(0)            ;; no forward TON
        .store_uint(0, 1)          ;; no forward payload
        .end_cell();

    send_raw_message(msg, 0);
    ;; No bounce handler exists in recv_internal
}

() recv_internal(int my_balance, int msg_value, cell in_msg_full, slice in_msg_body) impure {
    slice cs = in_msg_full.begin_parse();
    int flags = cs~load_uint(4);

    if (is_bounced?(flags)) {
        return ();  ;; Bounce silently ignored — funds lost
    }

    ;; ... normal message handling ...
}
```

## Mitigations

- Implement a bounce handler in `recv_internal` that parses the bounced message opcode and reverts the corresponding state changes (e.g., restores the user's balance).
- Use non-bounceable messages (`0x10` flag instead of `0x18`) when the destination contract is already validated and the message does not need to bounce, such as when creating new wallets.
- As per TON documentation, creating new accounts cannot be done with a bounceable message — use non-bounceable messages for account initialization.
- Review all outgoing messages in the contract and ensure that every bounceable message has a corresponding bounce handler.
