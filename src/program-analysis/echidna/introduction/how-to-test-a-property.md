# Testing a Property with Echidna

**Table of Contents:**

- [Testing a Property with Echidna](#testing-a-property-with-echidna)
  - [Introduction](#introduction)
  - [Write a Property](#write-a-property)
  - [Initiate a Contract](#initiate-a-contract)
  - [Run Echidna](#run-echidna)
  - [Summary: Testing a Property](#summary-testing-a-property)

## Introduction

This tutorial demonstrates how to test a smart contract with Echidna. The target is the following smart contract (_[token.sol](https://github.com/crytic/building-secure-contracts/blob/master/program-analysis/echidna/example/token.sol)_):

```solidity
contract Token {
    mapping(address => uint256) public balances;

    function airdrop() public {
        balances[msg.sender] = 1000;
    }

    function consume() public {
        require(balances[msg.sender] > 0);
        balances[msg.sender] -= 1;
    }

    function backdoor() public {
        balances[msg.sender] += 1;
    }
}
```

We will assume that this token has the following properties:

- Anyone can hold a maximum of 1000 tokens.

- The token cannot be transferred (it is not an ERC20 token).

## Write a Property

Echidna properties are Solidity functions. A property must:

- Have no arguments.

- Return true if successful.

- Have its name starting with `echidna`.

Echidna will:

- Automatically generate arbitrary transactions to test the property.

- Report any transactions that lead a property to return false or throw an error.

- Discard side-effects when calling a property (i.e., if the property changes a state variable, it is discarded after the test).

The following property checks that the caller can have no more than 1000 tokens:

```solidity
function echidna_balance_under_1000() public view returns (bool) {
    return balances[msg.sender] <= 1000;
}
```

Use inheritance to separate your contract from your properties:

```solidity
contract TestToken is Token {
    function echidna_balance_under_1000() public view returns (bool) {
        return balances[msg.sender] <= 1000;
    }
}
```

_[testtoken.sol](https://github.com/crytic/building-secure-contracts/blob/master/program-analysis/echidna/example/testtoken.sol)_ implements the property and inherits from the token.

## Initiate a Contract

Echidna requires a constructor without input arguments.
If your contract needs specific initialization, you should do it in the constructor.

There are some specific addresses in Echidna:

- `0x30000` calls the constructor.

- `0x10000`, `0x20000`, and `0x30000` randomly call other functions.

We don't need any particular initialization in our current example. As a result, our constructor is empty.

## Run Echidna

Launch Echidna with:

```bash
echidna contract.sol
```

If `contract.sol` contains multiple contracts, you can specify the target:

```bash
echidna contract.sol --contract MyContract
```

## Summary: Testing a Property

The following summarizes the Echidna run on our example:

```solidity
contract TestToken is Token {
    constructor() public {}

    function echidna_balance_under_1000() public view returns (bool) {
        return balances[msg.sender] <= 1000;
    }
}
```

```bash
echidna testtoken.sol --contract TestToken
...

echidna_balance_under_1000: failed!💥
  Call sequence, shrinking (1205/5000):
    airdrop()
    backdoor()

...
```

Echidna found that the property is violated if the `backdoor` function is called.
