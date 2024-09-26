# Inner Transaction Fee

Inner transaction fees are by default set to an estimated amount which are deducted from the application account if it is the Sender. An attacker can perform operations executing inner transactions and drain system funds, making it under-collateralized.

## Description

Inner transactions are initialized with Sender set to the application account and Fee to the minimum allowable, taking into account MinTxnFee and credit from overpaying in earlier transactions. The inner transaction fee depends on the transaction fee paid by the user. As a result, the user controls, to some extent, the fee paid by the application.

If the application does not explicitly set the Fee to zero, an attacker can burn the application’s balance in the form of fees. This also becomes an issue if the application implements internal bookkeeping to track the application balance and does not account for fees.

## Exploit Scenarios

```py
@router.method(no_op=CallConfig.CALL)
def mint(pay: abi.PaymentTransaction) -> Expr:
    return Seq([
            # perform validations and other operations
            # [...]
            # mint wrapped-asset id
            InnerTxnBuilder.Begin(),
            InnerTxnBuilder.SetFields(
                {
                    TxnField.type_enum: TxnType.AssetTransfer,
                    TxnField.asset_receiver: Txn.sender(),
                    TxnField.xfer_asset: wrapped_algo_asset_id,
                    TxnField.asset_amount: pay.get().amount(),
                }
            ),
            InnerTxnBuilder.Submit(),
            # [...]
    ])
```

The application does not explicitly set the inner transaction fee to zero. When user mints wrapped-algo, some of the ALGO is burned in the form of fees. The amount of wrapped-algo in circulation will be greater than the application ALGO balance. The system will be under-collateralized.

## Recommendations

Explicitly set the inner transaction fees to zero and use the fee pooling feature of the Algorand.
