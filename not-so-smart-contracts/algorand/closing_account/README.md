# Closing Accounts

A lack of checks for the CloseRemainderTo transaction field in smart signatures allows attackers to transfer the entire funds of a contract account or a delegator's account to their own account.

## Description

Algorand accounts must meet the minimum balance requirement, and the protocol rejects transactions if their execution would result in an account balance lower than the required minimum. To transfer the entire balance and close an account, users should use the CloseRemainderTo field of a payment transaction. Setting the CloseRemainderTo field transfers the remaining account balance after transaction execution to the specified address.

Any user with access to the smart signature can construct and submit transactions using that smart signature. To avoid unintended fund transfers, smart signatures approving payment transactions must ensure that the CloseRemainderTo field is set to the ZeroAddress or another specific address.

## Exploit Scenarios

A user creates a delegate signature for recurring payments. An attacker creates a valid transaction and sets the CloseRemainderTo field to their own address.

## Examples

Note: This code contains several other vulnerabilities. See [Rekeying](../rekeying), [Unchecked Transaction Fees](../unchecked_transaction_fee), [Time-based Replay Attack](../time_based_replay_attack).

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

Before approving a transaction in the Teal contract, verify that the CloseRemainderTo field is set to the ZeroAddress or another intended address.
