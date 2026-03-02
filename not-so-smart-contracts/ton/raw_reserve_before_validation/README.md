# Raw Reserve Before Validation

Calling `raw_reserve` before input validation locks deposited TON permanently when subsequent checks fail.

## Description

The `raw_reserve` function in FunC reserves a specified amount of TON in the contract's balance, making it unavailable for outgoing messages in the current transaction. If `raw_reserve` is called before validation checks (such as gas sufficiency or input validation), and a subsequent check fails, the contract may attempt to refund the user but cannot access the reserved funds. The refund message is sent with insufficient value, and the reserved TON becomes permanently locked in the contract.

This pattern is especially dangerous in deposit flows where the contract receives TON from a user, reserves it for protocol accounting, and then validates whether the user provided enough gas for the operation. If the gas check fails after the reserve, the user's deposited TON is trapped.

## Exploit Scenario

Alice deploys a lending protocol that accepts TON deposits. The protocol's supply function calls `raw_reserve` to lock the deposited amount before validating gas. Bob sends a deposit of 10 TON but attaches only a minimal gas fee. The contract calls `raw_reserve(10 TON, 2)`, locking the 10 TON. It then checks whether Bob sent enough gas for the subsequent message cascade and determines the fee is insufficient. The contract attempts to refund Bob using `CARRY_ALL_BALANCE` mode, but the reserved 10 TON is excluded from the available balance. Bob receives a near-zero refund, and his 10 TON is permanently locked in the contract.

## Example

The following simplified code shows a supply function that reserves the user's deposit before checking whether enough gas was provided. If the gas check fails, the refund cannot access the reserved funds.

```FunC
;; Called when user supplies TON to the protocol
() supply_withdraw_ton(int supply_amount, int msg_value, slice sender,
                       int fwd_fee, cell custom_payload) impure inline {
    ;; Reserve the supply amount BEFORE any validation
    raw_reserve(supply_amount, 2);  ;; Funds now locked

    return master_core_logic(
        supply_amount, msg_value, sender, fwd_fee, custom_payload
    );
}

() master_core_logic(int supply_amount, int msg_value, slice sender,
                     int fwd_fee, cell custom_payload) impure {
    int enough_fee = calculate_required_fee(fwd_fee);

    if (msg_value < enough_fee) {
        ;; Gas check failed — try to refund
        cell body = begin_cell()
            .store_uint(error::insufficient_fee, 32)
            .store_uint(0, 64)
            .end_cell();

        ;; This message cannot access the reserved funds
        ;; User's TON is permanently locked
        send_raw_message(
            begin_cell()
                .store_uint(0x10, 6)
                .store_slice(sender)
                .store_coins(0)
                .store_uint(1, 107)
                .store_ref(body)
                .end_cell(),
            128  ;; CARRY_ALL_BALANCE — but reserved funds are excluded
        );
        return ();
    }

    ;; ... process supply ...
}
```

## Mitigations

- Perform all validation checks (gas sufficiency, input validation, access control) before calling `raw_reserve`.
- Structure the code so that `raw_reserve` is the last operation before sending the final outgoing message, not the first.
- Implement a recovery mechanism for locked funds in case similar issues occur, such as an admin-callable sweep function.
- Add tests that verify refund paths return the correct amount of TON to the user, including cases where validation fails.
