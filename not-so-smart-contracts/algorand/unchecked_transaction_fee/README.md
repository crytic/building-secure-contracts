# Unchecked Transaction Fee

The absence of a transaction fee check in smart signatures allows malicious users to drain a contract account or a delegator's account by specifying excessive fees.

## Description

Any user can submit transactions using smart signatures and decide on the transaction fields. It is the creator's responsibility to enforce restrictions on all transaction fields to prevent malicious users from misusing the smart signature.

One of these transaction fields is the Fee. The Fee field specifies the number of micro-algos paid for processing the transaction. The protocol only verifies that the transaction pays a fee greater than the protocol-decided minimum fee. If a smart signature doesn't limit the transaction fee, a user could set an excessive fee and drain the sender's funds. The sender will be the signer of the Teal program in the case of a delegate signature, and the contract account otherwise.

## Exploit Scenarios

A user creates a delegate signature for recurring payments. An attacker creates a valid transaction and drains the user's funds by specifying an excessive fee.

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

- Set the transaction fee to `0` and use fee pooling. If users need to call the smart signature outside of a group, set the transaction fee to the minimum transaction fee: `global MinTxnFee`.
