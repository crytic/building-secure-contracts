# Rekeying

A lack of verification for the RekeyTo field in a Teal program may allow malicious actors to rekey the associated account and control its assets directly, bypassing the restrictions imposed by the Teal contract.

## Description

Rekeying is an Algorand feature that enables users to transfer the authorization power of their account to a different account. When an account has been rekeyed, any future transactions from that account will be accepted by the blockchain only if they have been authorized by the rekeyed account.

A user can rekey their account to a chosen account by sending a rekey-to transaction with the RekeyTo field set to the target account address. A rekey-to transaction is a transaction that has the RekeyTo field set to a well-formed Algorand address. Any Algorand account, including contract accounts, can be rekeyed by sending a rekey-to transaction from that account.

Contract accounts are accounts controlled by Teal code. Anyone can set fields and submit transactions from a contract account as long as they pass the checks enforced in the Teal code. If the Teal code approves a transaction that passes specific checks but does not verify the RekeyTo field, a malicious user can send a transaction approved by the Teal code with the RekeyTo field set to their account. After rekeying, the attacker can transfer assets and Algos directly by authorizing transactions with their private key.

A similar issue affects accounts that have created a delegate signature by signing a Teal program. The delegator only needs to sign the contract, and any user with access to the delegate signature can construct and submit transactions. Due to this, a malicious user can rekey the sender's account if the Teal logic accepts a transaction with the RekeyTo field set to a user-controlled address.

Note: Starting from Teal v6, applications can also be rekeyed by executing an inner transaction with the "RekeyTo" field set to a non-zero address. Rekeying an application allows for bypassing the application logic and directly transferring Algos and assets of the application account.

## Exploit Scenarios

A user creates a delegate signature for recurring payments. An attacker rekeys the sender's account by specifying the RekeyTo field in a valid payment transaction.

## Example

Note: This code contains several other vulnerabilities, including [Unchecked Transaction Fees](../unchecked_transaction_fee), [Closing Account](../closing_account), and [Time-based Replay Attack](../time_based_replay_attack).

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

- For Teal programs written in Teal version 2 or greater, either used as a delegate signature or contract account, include a check in the program that verifies the RekeyTo field to be equal to the ZeroAddress or any intended address. Teal contracts written in Teal version 1 are not affected by this issue. The rekeying feature was introduced in version 2, and Algorand rejects transactions that use features introduced in later versions than the executed Teal program version.

- Use [Tealer](https://github.com/crytic/tealer) to detect this issue.

- For Applications, verify that user-provided values are not used for the `RekeyTo` field of an inner transaction. Additionally, avoid rekeying an application to an admin-controlled address, as this allows the possibility of a "rug pull" by a malicious admin.
