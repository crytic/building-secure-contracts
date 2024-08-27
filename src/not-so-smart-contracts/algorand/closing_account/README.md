# Closing Account

Lack of check for CloseRemainderTo transaction field in smart signatures allows attackers to transfer entire funds of the contract account or the delegator’s account to their account.

## Description

Algorand accounts must satisfy minimum balance requirement and protocol rejects transactions whose execution results in account balance lower than the required minimum. In order to transfer the entire balance and close the account, users should use the CloseRemainderTo field of a payment transaction. Setting the CloseRemainderTo field transfers the entire account balance remaining after transaction execution to the specified address.

Any user with access to the smart signature may construct and submit the transactions using the smart signature. The smart signatures approving payment transactions have to ensure that the CloseRemainderTo field is set to the ZeroAddress or any other specific address to avoid unintended transfer of funds.

## Exploit Scenarios

A user creates a delegate signature for recurring payments. Attacker creates a valid transaction and sets the CloseRemainderTo field to their address.

## Examples

Note: This code contains several other vulnerabilities, see [Rekeying](../rekeying), [Unchecked Transaction Fees](../unchecked_transaction_fee), [Time-based Replay Attack](../time_based_replay_attack).

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

Verify that the CloseRemainderTo field is set to the ZeroAddress or to any intended address before approving the transaction in the Teal contract.
