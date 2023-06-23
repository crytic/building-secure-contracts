# Time-based Replay Attack

A lack of checks for the lease field in smart signatures, which are meant to approve a single transaction within a specific period, allows attackers to submit multiple valid transactions during that timeframe.

## Description

Algorand prevents transaction replay attacks by using a validity period. A transaction's validity period comprises the sequence of blocks between the FirstValid and LastValid blocks. A transaction is considered valid only within that period, and a transaction with the same hash can be processed only once during that timeframe. Furthermore, Algorand limits the validity period to a maximum of 1000 blocks. This allows the transaction creator to appropriately select the FirstValid and LastValid fields, ensuring that the transaction is processed only once within that period.

However, this does not apply to transactions authorized by smart signatures. Even if the contract developer sets the FirstValid and LastValid transaction fields to fixed values, an attacker can still submit multiple transactions that comply with the contract because any user can create and submit transactions authorized by a smart signature. The attacker can craft transactions with identical values for most fields—those verified by the contract—and slightly different values for the remaining fields. Each of these transactions will have a unique hash and will be accepted by the protocol.

## Exploit Scenarios

A user creates a delegate signature for recurring payments. The contract confirms the FirstValid and LastValid fields to permit only one transaction each time. However, an attacker can create and submit multiple valid transactions with different hashes.

## Examples

Note: This code contains several other vulnerabilities; see [Rekeying](../rekeying), [Unchecked Transaction Fees](../unchecked_transaction_fee), and [Closing Account](../closing_account).

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

Verify that the Lease field of the transaction is set to a specific value. Lease enforces mutual exclusion; once a transaction with a non-zero lease is confirmed by the protocol, no other transactions with the same lease and sender will be accepted until the LastValid block.
