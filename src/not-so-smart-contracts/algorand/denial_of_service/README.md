# Denial of Service

When a contract does not verify whether an account has opted in to an asset and attempts to transfer that asset, an attacker can DoS other users if the contract's operation is to transfer asset to multiple accounts.

## Description

A user must explicitly opt-in to receive any particular Algorand Standard Asset(ASAs). A user may also opt out of an ASA. A transaction will fail if it attempts to transfer tokens to an account that didn’t opt in to that asset. This could be leveraged by attackers to DOS a contract if the contract’s operation depends on successful transfer of an asset to the attacker owned address.

## Exploit Scenarios

Contract attempts to transfer assets to multiple users. One user is not opted in to the asset. The transfer operation fails for all users.

## Examples

Note: This code contains several other vulnerabilities, see [Rekeying](../rekeying), [Unchecked Transaction Fees](../unchecked_transaction_fee), [Closing Asset](../closing_asset), [Group Size Check](../group_size_check), [Time-based Replay Attack](../time_based_replay_attack), [Asset Id Check](../asset_id_check)

```py
def split_and_withdraw_asset(
    amount_1,
    receiver_1,
    amount_2,
    receiver_2,
    lock_expire_round,
):
    return And(
        Gtxn[0].type_enum() == TxnType.AssetTransfer,
        Gtxn[0].asset_receiver() == receiver_1,
        Gtxn[0].asset_amount() == amount_1,

        Gtxn[1].type_enum() == TxnType.AssetTransfer,
        Gtxn[1].receiver() == receiver_2,
        Gtxn[1].amount() == amount_2,

        Gtxn[0].first_valid == lock_expire_round,
    )
```

## Recommendations

Use pull over push pattern for transferring assets to users.
