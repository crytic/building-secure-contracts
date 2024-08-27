# Unchecked Transaction Fee

Lack of transaction fee check in smart signatures allows malicious users to drain the contract account or the delegator’s account by specifying excessive fees.

## Description

Any user can submit transactions using the smart signatures and decide on the transaction fields. It is the responsibility of the creator to enforce restrictions on all the transaction fields to prevent malicious users from misusing the smart signature.

One of these transaction fields is Fee. Fee field specifies the number of micro-algos paid for processing the transaction. Protocol only verifies that the transaction pays a fee greater than protocol decided minimum fee. If a smart signature doesn’t bound the transaction fee, a user could set an excessive fee and drain the sender funds. Sender will be the signer of the Teal program in case of delegate signature and the contract account otherwise.

## Exploit Scenarios

A user creates a delegate signature for recurring payments. Attacker creates a valid transaction and drains the user funds by specifying excessive fee.

## Examples

Note: This code contains several other vulnerabilities, see [Rekeying](../rekeying), [Closing Account](../closing_account), [Time-based Replay Attack](../time_based_replay_attack).

```py
def withdraw(
    duration,
    period,
    amount,
    receiver,
    timeout,
):
    return And(
        Txn.type_enum() == TxnType.Payment,
        Txn.first_valid() % period == Int(0),
        Txn.last_valid() == Txn.first_valid() + duration,
        Txn.receiver() == receiver,
        Txn.amount() == amount,
        Txn.first_valid() < timeout,
    )
```

## Recommendations

- Force the transaction fee to be `0` and use fee pooling. If the users should be able to call the smart signature outside of a group, force the transaction fee to be minimum transaction fee: `global MinTxnFee`.
