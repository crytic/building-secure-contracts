# Time-based Replay Attack

Lack of check for lease field in smart signatures that intend to approve a single transaction in the particular period allows attackers to submit multiple valid transactions in that period.

## Description

Algorand stops transaction replay attacks using a validity period. A validity period of a transaction is the sequence of blocks between FirstValid block and LastValid block. The transaction is considered valid only in that period and a transaction with the same hash can be processed only once in that period. Algorand also limits the period to a maximum of 1000 blocks. This allows the transaction creator to select the FirstValid, LastValid fields appropriately and feel assured that the transaction is processed only once in that period.

However, The same does not apply for transactions authorized by smart signatures. Even if the contract developer verifies the FirstValid and LastValid transaction fields to fixed values, an attacker can submit multiple transactions that are valid as per the contract. This is because any user can create and submit transactions authorized by a smart signature. The attacker can create transactions which have equal values for most transaction fields, for fields verified in the contract and slightly different values for the rest. Each one of these transactions will have a different hash and will be accepted by the protocol.

## Exploit Scenarios

A user creates a delegate signature for recurring payments. Contract verifies the FirstValid and LastValid to only allow a single transaction each time. Attacker creates and submits multiple valid transactions with different hashes.

## Examples

Note: This code contains several other vulnerabilities, see [Rekeying](../rekeying), [Unchecked Transaction Fees](../unchecked_transaction_fee), [Closing Account](../closing_account).

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

Verify that the Lease field of the transaction is set to a specific value. Lease enforces mutual exclusion, once a transaction with non-zero lease is confirmed by the protocol, no other transactions with same lease and sender will be accepted till the LastValid block
