# Clear State Transaction Check

The lack of checks on the OnComplete field of the application calls might allow an attacker to execute the clear state program instead of the approval program, breaking core validations.

## Description

Algorand applications make use of group transactions to realize operations that may not be possible using a single transaction model. Some operations require that other transactions in the group call certain methods and applications. These requirements are asserted by validating that the transactions are ApplicationCall transactions. However, the OnComplete field of these transactions is not always validated, allowing an attacker to submit ClearState ApplicationCall transactions. The ClearState transaction invokes the clear state program instead of the intended approval program of the application.

## Exploit Scenario

A protocol offers flash loans from a liquidity pool. The flash loan operation is implemented using two methods: `take_flash_loan` and `pay_flash_loan`. `take_flash_loan` method transfers the assets to the user and `pay_flash_loan` verifies that the user has returned the borrowed assets. `take_flash_loan` verifies that a later transaction in the group calls the `pay_flash_loan` method. However, It does not validate the OnComplete field.

```py
@router.method(no_op=CallConfig.CALL)
def take_flash_loan(offset: abi.Uint64, amount: abi.Uint64) -> Expr:
    return Seq([
        # Ensure the pay_flash_loan method is called
        Assert(And(
            Gtxn[Txn.group_index() + offset.get()].type_enum == TxnType.ApplicationCall,
            Gtxn[Txn.group_index() + offset.get()].application_id() == Global.current_application_id(),
            Gtxn[Txn.group_index() + offset.get()].application_args[0] == MethodSignature("pay_flash_loan(uint64)")
        )),
        # Perform other validations, transfer assets to the user, update the global state
        # [...]
    ])

@router.method(no_op=CallConfig.CALL)
def pay_flash_loan(offset: abi.Uint64) -> Expr:
    return Seq([
        # Validate the "take_flash_loan" transaction at `Txn.group_index() - offset.get()`
        # Ensure the user has returned the funds to the pool along with the fee. Fail the transaction otherwise
        # [...]
    ])
```

An attacker constructs a valid group transaction for flash loan but sets the OnComplete field of `pay_flash_loan` call to ClearState. The clear state program is executed for complete_flash_loan call, which does not validate that the attacker has returned the funds. The attacker steals all the assets in the pool.

## Recommendations

Validate the OnComplete field of the ApplicationCall transactions.
