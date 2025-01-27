# Fake Jetton Contract

TON smart contracts use the `transfer_notification` message sent by the receiver's Jetton wallet contract to specify and process a user request along with the transfer of a Jetton. Users add a `forward_payload` to the Jetton `transfer` message when transferring their Jettons, this `forward_payload` is forwarded by the receiver's Jetton wallet contract to the receiver in the `transfer_notification` message. The `transfer_notification` message has the following TL-B schema:

```
transfer_notification#7362d09c query_id:uint64 amount:(VarUInteger 16)
                              sender:MsgAddress forward_payload:(Either Cell ^Cell)
                              = InternalMsgBody;
```

The `amount` and `sender` are added by the receiver's Jetton wallet contract as the amount of Jettons transferred and the sender of Jettons (owner of the Jetton wallet that sent of the `internal_transfer` message). However, all the other values specified by the user in the `forward_payload` are not parsed or validated by the Jetton wallet contract, they are added as it and sent in the `transfer_notification` message. Therefore, the receiver of the `transfer_notification` message must consider malicious values in the `forward_payload` and validate them properly to prevent any contract state manipulation.

## Example

The following simplified code highlights the lack of token_id validation in the `transfer_notification` message. This contract tracks user deposits by updating the `token0_balances` dictionary entry for the user's address. However, the `transfer_notification` message handler does not verify that the `sender_address` is equal to one of the `token0` or `token1` Jetton wallets owned by this contract. This allows users to manipulate their deposit values by sending the `transfer_notification` message from a fake Jetton wallet contract.

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

    (cell token0_balances, cell token1_balances) = load_data(); ;; balances dictionaries

    (int op, int query_id) = in_msg_body~load_op_and_query_id();

    if (op == op::transfer_notification) {
        (int amount, slice from_address) = (in_msg_body~load_coins(), in_msg_body~load_msg_addr());
        cell forward_payload_ref = in_msg_body~load_ref();
        slice forward_payload = forward_payload_ref.begin_parse();

        int is_token0? = forward_payload~load_int(1);

        if (is_token0?) {
            slice balance_before = token0_balances.dict_get?(267, from_address);
            int balance = balance_before~load_coins();
            balance = balance + amount;
            slice balance_after = begin_cell().store_coinds(balance).end_cell().being_parse();
            token0_balances~dict_set(267, from_address, balance_after);
        } else {
            slice balance_before = token1_balances.dict_get?(267, from_address);
            int balance = balance_before~load_coins();
            balance = balance + amount;
            slice balance_after = begin_cell().store_coinds(balance).end_cell().being_parse();
            token1_balances~dict_set(267, from_address, balance_after);
        }

        save_data();
        return ();
    }
}
```

## Mitigations

- Store the address of Jetton wallet contract owned by the current contract at the time of contract initialization and use this stored value to verify the sender of the `transfer_notification` message.
- Validate all the user provided values in the `forward_payload` instead of trusting users to send correct values.
