# Rekeying

The lack of check for RekeyTo field in the Teal program allows malicious actors to rekey the associated account and control the account assets directly, bypassing the restrictions imposed by the Teal contract.

## Description

Rekeying is an Algorand feature which allows a user to transfer the authorization power of their account to a different account. When an account has been rekeyed, all the future transactions from that account are accepted by the blockchain, if and only if the transaction has been authorized by the rekeyed account.

A user can rekey their account to the selected account by sending a rekey-to transaction with rekey-to field set to the target account address. A rekey-to transaction is atransaction which has the rekey-to field set to a well formed Algorand address.
Any algorand account can be rekeyed by sending a rekey-to transaction from that account, this includes the contract accounts.

Contract accounts are accounts which are derived from the Teal code that is in control of that account. Anyone can set the fields and submit a transaction from the contract account as long as it passes the checks enforced in the Teal code. This results in an issue if the Teal code is supposed to approve a transaction that passes specific checks and does not check the rekey-to field. A malicious user can first send a transaction approved by the Teal code with rekey-to set to their account. After rekeying, the attacker can transfer the assets, algos directly by authorizing the transactions with their private key.

Similar issue affects the accounts that created a delegate signature by signing a Teal program. Delegator is only needed to sign the contract and any user with access to delegate signature can construct and submit transactions. Because of this, a malicious user can rekey the sender’s account if the Teal logic accepts a transaction with the rekey-to field set to the user controlled address.

Note: From Teal v6, Applications can also be rekeyed by executing an inner transaction with "RekeyTo" field set to a non-zero address. Rekeying an application allows to bypass the application logic and directly transfer Algos and assets of the application account.

## Exploit Scenarios

A user creates a delegate signature for recurring payments. Attacker rekeys the sender’s account by specifying the rekey-to field in a valid payment transaction.

## Example

Note: This code contains several other vulnerabilities, [Unchecked Transaction Fees](../unchecked_transaction_fee), [Closing Account](../closing_account), [Time-based Replay Attack](../time_based_replay_attack).

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

- For the Teal programs written in Teal version 2 or greater, either used as delegate signature or contract account, include a check in the program that verifies rekey-to field to be equal to ZeroAddress or any intended address. Teal contracts written in Teal version 1 are not affected by this issue. Rekeying feature is introduced in version 2 and Algorand rejects transactions that use features introduced in the versions later than the executed Teal program version.

- Use [Tealer](https://github.com/crytic/tealer) to detect this issue.

- For Applications, verify that user provided value is not used for `RekeyTo` field of a inner transaction. Additionally, avoid rekeying an application to admin controlled address. This allows for the possibility of "rug pull" by a malicious admin.
