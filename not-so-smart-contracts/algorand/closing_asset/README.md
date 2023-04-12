# Closing Asset

A lack of checks for the AssetCloseTo transaction field in smart signatures enables attackers to transfer the entire asset balance of the contract account or the delegator's account to their account.

## Description

Algorand supports Fungible and Non-Fungible Tokens using Algorand Standard Assets (ASA). An Algorand account must first opt-in to the asset before it can receive any tokens. Opting-in to an asset increases the minimum balance requirement of the account. Users can opt-out of the asset and decrease the minimum balance requirement by using the AssetCloseTo field of the Asset Transfer transaction. Setting the AssetCloseTo field transfers the account's entire token balance remaining after the transaction execution to the specified address.

Any user with access to the smart signature may construct and submit transactions using the smart signature. Smart signatures approving asset transfer transactions must ensure that the AssetCloseTo field is set to the ZeroAddress or any other specific address to prevent unintended token transfers.

## Exploit Scenarios

A user creates a delegate signature that allows recurring transfers of a certain asset. An attacker then creates a valid asset transfer transaction with the AssetCloseTo field set to their address.

## Examples

Note: This code contains several other vulnerabilities, such as [Rekeying](../rekeying), [Unchecked Transaction Fees](../unchecked_transaction_fee), [Closing Asset](../closing_asset), [Time-based Replay Attack](../time_based_replay_attack), and [Asset ID Check](../asset_id_check).

```py
def withdraw_asset(
    duration,
    period,
    amount,
    receiver,
    timeout,
):
    return And(
        Txn.type_enum() == TxnType.AssetTransfer,
        Txn.first_valid() % period == Int(0),
        Txn.last_valid() == Txn.first_valid() + duration,
        Txn.asset_receiver() == receiver,
        Txn.asset_amount() == amount,
        Txn.first_valid() < timeout,
    )
```

## Recommendations

Before approving the transaction in the Teal contract, make sure to verify that the AssetCloseTo field is set to the ZeroAddress or the intended address.
