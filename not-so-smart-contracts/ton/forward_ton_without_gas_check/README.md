# Foward TON without gas check

TON smart contracts needs to send TON as gas fee along with the Jetton transfers or any other message they send to another contract. If a contract allows its users to specify the amount of TON to be sent with an outgoing message then it must check that the user supplied enough TON with their message to cover for the transaction fee and the forward TON amount.

If a contract lacks such a gas check then users can specify a higher forward TON amount to drain the TON balance of the smart contract, freezing the smart contract and potentially destroying it.

## Example

The following simplified code highlights the lack of a gas check. The contract implements a `withdraw` operation that allows users to specify a forward TON amount and a forward payload to send with the Jettons. However, the contract does not check if the user included enough TON with the `withdraw` message to cover the `withdraw` message transaction, the Jetton transfer gas fee, and the forward TON amount. This allows users to drain the TON balance of the smart contract.

```FunC
#include "imports/stdlib.fc";

() recv_internal(int my_balance, int msg_value, cell in_msg_full, slice in_msg_body) impure {
    slice cs = in_msg_full.begin_parse();
    int flags = cs~load_uint(4);
    ;; ignore all bounced messages
    if (is_bounced?(flags)) {
        return ();
    }
    slice sender_address = cs~load_msg_addr(); ;; incorrectly assumed to be Jetton wallet contract owned by this contract

    (int op, int query_id) = in_msg_body~load_op_and_query_id();

    if (op == op::withdraw) {
        int amount = in_msg_body~load_coins();
        slice to_address = in_msg_body~load_msg_addr();
        int forward_ton_amount = in_msg_body~load_coins(); ;; user specified forward TON amount
        cell forward_payload = begin_cell().store_slice(in_msg_body).end_cell();

        var msg_body = begin_cell()
            .store_op_and_query_id(op::transfer, query_id)
            .store_coins(amount)
            .store_slice(to_address)
            .store_slice(to_address)
            .store_uint(0, 1)
            .store_coins(forward_ton_amount)
            .store_maybe_ref(forward_payload)
            .end_cell();

        cell msg = begin_cell()
            .store_uint(0x18, 6)
            .store_slice(USDT_WALLET_ADDRESS)
            .store_coins(JETTON_TRANSFER_GAS + forward_ton_amount) ;; sending user specified forward TON amount
            .store_uint(1, 1 + 4 + 4 + 64 + 32 + 1 + 1) ;; message parameters
            .store_ref(ref)
            .end_cell();

        send_raw_message(msg, 0);

        return ();
    }
}
```

## Mitigations

- Avoid allowing users to specify forward TON amount with the outgoing messages.
- Always check that the user sent enough TON in the `msg_value` to cover for the current transaction fee and sum of all the outgoing message values.
