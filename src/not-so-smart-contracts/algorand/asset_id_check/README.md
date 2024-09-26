# Asset Id Check

Lack of verification of asset id in the contract allows attackers to transfer a different asset in place of the expected asset and mislead the application.

## Description

Contracts accepting and doing operations based on the assets transferred to the contract must verify that the transferred asset is the expected asset by checking the asset Id. Absence of check for expected asset Id could allow attackers to manipulate contract’s logic by transferring a fake, less or more valuable asset instead of the correct asset.

## Exploit Scenarios

- A liquidity pool contract mints liquidity tokens on deposit of two tokens. Contract does not check that the asset Ids in the two asset transfer transactions are correct. Attacker deposits the same less valuable asset in the two transactions and withdraws both tokens by burning the pool tokens.
- User creates a delegate signature that allows recurring transfers of a certain asset. Attacker creates a valid asset transfer transaction of more valuable assets.

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

Verify the asset id to be expected asset for all asset related operations in the contract.
