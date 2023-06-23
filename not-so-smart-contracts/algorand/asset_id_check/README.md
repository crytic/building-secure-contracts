# Asset ID Check

Failing to verify the asset ID in a contract can allow attackers to transfer a different asset instead of the expected one, potentially misleading the application.

## Description

Contracts that accept and perform operations based on assets transferred to them must verify that the transferred asset is indeed the expected asset by checking the asset ID. Neglecting to check the expected asset ID could enable attackers to manipulate the contract's logic by transferring a fake, less valuable, or more valuable asset instead of the correct one.

## Exploit Scenarios

- A liquidity pool contract mints liquidity tokens upon the deposit of two tokens. The contract does not verify that the asset IDs in the two asset transfer transactions are correct. The attacker deposits the same, less valuable asset in both transactions and withdraws both tokens by burning the pool tokens.
- A user creates a delegate signature that permits recurring transfers of a certain asset. The attacker then generates a valid asset transfer transaction involving more valuable assets.

## Examples

Note: This code contains several other vulnerabilities, see [Rekeying](../rekeying), [Unchecked Transaction Fees](../unchecked_transaction_fee), [Closing Asset](../closing_asset), [Time-based Replay Attack](../time_based_replay_attack).

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

Ensure that the asset ID is verified as the expected asset for all asset-related operations in the contract.
