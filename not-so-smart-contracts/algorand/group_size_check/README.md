# Group Size Check

Lack of group size check in contracts that are supposed to be called in an atomic group transaction might allow attackers to misuse the application.

## Description

Algorand supports atomic transfers, an atomic transfer is a group of transactions that are submitted and processed as a single transaction. A group can contain upto 16 transactions and the group transaction fails if any of the included transactions fails. Algorand applications make use of group transactions to realize operations that may not be possible using a single transaction model. In such cases, it is necessary to check that the group transaction in itself is valid along with the individual transactions. One of the checks whose absence could be misused is group size check.

## Exploit Scenarios

Application only checks that transactions at particular indices are meeting the criteria and performs the operations based on that. Attackers can create the transactions at the checked indices correctly and include equivalent application call transactions at all the remaining indices. Each application call executes successfully as every execution checks the same set of transactions. This results in performing operations multiple times, once for each application call. This could be damaging if those operations include funds or assets transfers among others.

## Examples

Note: This code contains several other vulnerabilities, see [Rekeying](../rekeying), [Unchecked Transaction Fees](../unchecked_transaction_fee), [Closing Account](../closing_account), [Time-based Replay Attack](../time_based_replay_attack).

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

- Verify that the group size of an atomic transfer is the intended size in the contracts.

- Use [Tealer](https://github.com/crytic/tealer) to detect this issue.

- Favor using ABI for smart contracts and relative indexes to verify the group transaction.
