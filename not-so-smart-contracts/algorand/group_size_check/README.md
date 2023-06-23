# Group Size Check

A lack of group size check in contracts intended for atomic group transactions might allow attackers to misuse the application.

## Description

Algorand supports atomic transfers, which are groups of transactions that are submitted and processed as a single transaction. A group can contain up to 16 transactions, and the group transaction fails if any of the included transactions fail. Algorand applications utilize group transactions to perform operations that might not be possible using a single transaction model. In such cases, it is necessary to verify that the group transaction itself is valid, along with the individual transactions. One check that, if absent, could be exploited is the group size check.

## Exploit Scenarios

An application might only verify that transactions at particular indices meet the criteria and perform operations based on that. Attackers can create the transactions at the checked indices correctly and include equivalent application call transactions at all remaining indices. Each application call executes successfully since every execution checks the same set of transactions. This results in performing operations multiple times: once for each application call. This could be damaging if those operations involve funds or asset transfers, among other things.

## Examples

Note: This code contains several other vulnerabilities, see [Rekeying](../rekeying), [Unchecked Transaction Fees](../unchecked_transaction_fee), [Closing Account](../closing_account), and [Time-based Replay Attack](../time_based_replay_attack).

```py
def split_and_withdraw(
    amount_1,
    receiver_1,
    amount_2,
    receiver_2,
    lock_expire_round,
):
    return And(
        Gtxn[0].type_enum() == TxnType.Payment,
        Gtxn[0].receiver() == receiver_1,
        Gtxn[0].amount() == amount_1,

        Gtxn[1].type_enum() == TxnType.Payment,
        Gtxn[1].receiver() == receiver_2,
        Gtxn[1].amount() == amount_2,

        Gtxn[0].first_valid == lock_expire_round,
    )
```

## Recommendations

- Ensure that contracts verify the intended group size of an atomic transfer.

- Use [Tealer](https://github.com/crytic/tealer) to detect this issue.

- Favor using an Application Binary Interface (ABI) for smart contracts and relative indexes to verify group transactions.
