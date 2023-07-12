# Using ether during a fuzzing campaign

**Table of contents:**

- [Using ether during a fuzzing campaign](#using-ether-during-a-fuzzing-campaign)
  - [Introduction](#introduction)
  - [Controlling the amount of ether in payable functions](#controlling-the-amount-of-ether-in-payable-functions)
  - [Controlling the amount of ether in contracts](#controlling-the-amount-of-ether-in-contracts)
  - [Summary: Working with ether](#summary-working-with-ether)

## Introduction

We will see how to use ether during a fuzzing campaign. The following smart contract will be used as example:

```solidity
contract C {
    function pay() public payable {
        require(msg.value == 12000);
    }

    function echidna_has_some_value() public returns (bool) {
        return (address(this).balance != 12000);
    }
}
```

This code forces Echidna to send a particular amount of ether as value in the `pay` function.
Echidna will do this for each payable function in the target function (or any contract if `allContracts` is enabled):

```
$ echidna balanceSender.sol
...
echidna_has_some_value: failed!💥
  Call sequence:
    pay() Value: 0x2ee0
```

Echidna will show the value amount in hexadecimal.

## Controlling the amount of ether in payable functions

The amount of ether to send in each payable function will be randomly selected, but with a maximum value determined by the `maxValue` value
with a default of 100 ether per transaction:

```yaml
maxValue: 100000000000000000000
```

This means that each transaction will contain, at most, 100 ether in value. However, there is no maximum that will be used in total.
The maximum amount to receive will be determined by the number of transactions. If you are using 100 transactions (`--seq-len 100`),
then the total amount of ether used for all the transactions will be between 0 and 100 \* 100 ethers.

Keep in mind that the balance of the senders (e.g. `msg.sender.balance`) is a fixed value that will NOT change between transactions.
This value is determined by the following config option:

```yaml
balanceAddr: 0xffffffff
```

## Controlling the amount of ether in contracts

Another approach to handle ether will be allow the testing contract to receive certain amount and then use it to send it.

```solidity
contract A {
    C internal c;

    constructor() public payable {
        require(msg.value == 12000);
        c = new C();
    }

    function payToContract(uint256 toPay) public {
        toPay = toPay % (address(this).balance + 1);
        c.pay{ value: toPay }();
    }

    function echidna_C_has_some_value() public returns (bool) {
        return (address(c).balance != 12000);
    }
}

contract C {
    function pay() public payable {
        require(msg.value == 12000);
    }
}
```

However, if we run this directly with echidna, it will fail:

```
$ echidna balanceContract.sol
...
echidna: Deploying the contract 0x00a329c0648769A73afAc7F9381E08FB43dBEA72 failed (revert, out-of-gas, sending ether to an non-payable constructor, etc.):
```

We need to define the amount to send during the contract creation:

```yaml
balanceContract: 12000
```

We can re-run echidna, using that config file, to obtain the expected result:

```
$ echidna balanceContract.sol --config balanceContract.yaml
...
echidna_C_has_some_value: failed!💥
  Call sequence:
    payToContract(12000)
```

## Summary: Working with ether

Echidna has two options for using ether during a fuzzing campaign.

- `maxValue` to set the max amount of ether per transaction
- `contractBalance` to set the initial amount of ether that the testing contract receives in the constructor.
