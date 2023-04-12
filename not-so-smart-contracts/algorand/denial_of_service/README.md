# Denial of Service

A denial of service (DoS) attack can occur when a contract does not verify whether an account has opted into an asset and then attempts to transfer that asset. If the contract's operation involves transferring an asset to multiple accounts, an attacker can use this weakness to launch a DoS attack against other users.

## Description

A user must explicitly opt into receiving any particular Algorand Standard Asset (ASA). A user may also choose to opt out of an ASA. A transaction will fail if it attempts to transfer tokens to an account that has not opted into that asset. Attackers can exploit this vulnerability by launching a DoS attack on a contract if the contract's operation depends on a successful asset transfer to an attacker-owned address.

## Exploit Scenarios

A contract tries to transfer assets to multiple users. However, one user has not opted into the asset, causing the transfer operation to fail for all users.

## Examples

Note: This code contains several other vulnerabilities. See [Rekeying](../rekeying), [Unchecked Transaction Fees](../unchecked_transaction_fee), [Closing Asset](../closing_asset), [Group Size Check](../group_size_check), [Time-based Replay Attack](../time_based_replay_attack), and [Asset ID Check](../asset_id_check)

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

Employ the pull-over-push pattern for transferring assets to users.
