# Closing Asset

Lack of check for AssetCloseTo transaction field in smart signatures allows attackers to transfer the entire asset balance of the contract account or the delegator’s account to their account.

## Description

Algorand supports Fungible and Non Fungible Tokens using Algorand Standard Assets(ASA). An Algorand account must first opti-in to the asset before that account can receive any tokens. Opting to an asset increases the minimum balance requirement of the account. Users can opt-out of the asset and decrease the minimum balance requirement using the AssetCloseTo field of Asset Transfer transaction. Setting the AssetCloseTo field transfers the account’s entire token balance remaining after transaction execution to the specified address.

Any user with access to the smart signature may construct and submit the transactions using the smart signature. The smart signatures approving asset transfer transactions have to ensure that the AssetCloseTo field is set to the ZeroAddress or any other specific address to avoid unintended transfer of tokens.

## Exploit Scenarios

User creates a delegate signature that allows recurring transfers of a certain asset. Attacker creates a valid asset transfer transaction with AssetCloseTo field set to their address.

## Examples

Note: This code contains several other vulnerabilities, see [Rekeying](../rekeying), [Unchecked Transaction Fees](../unchecked_transaction_fee), [Closing Asset](../closing_asset), [Time-based Replay Attack](../time_based_replay_attack), [Asset Id Check](../asset_id_check).

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

Verify that the AssetCloseTo field is set to the ZeroAddress or to the intended address before approving the transaction in the Teal contract.
