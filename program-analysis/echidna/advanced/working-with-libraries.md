# Working with external libraries

**Table of contents:**

- [Introduction](#introduction)
- [Example code](#example-code)
- [Deploying libraries](#deploying-libraries)
- [Linking libraries](#linking-libraries)
- [Summary](#summary)

## Introduction

Solidity introduced a the concept of a smart contract library. Before continue, it is very recommended to review [the official Solidity documentation](https://docs.soliditylang.org/en/v0.8.19/contracts.html#libraries) to make sure
you understand how libraries are created and deployed. When a user creates a library, Solidity will do one of these two options:

- If all the functions are internal, the library is compiled into bytecode and added into the contracts that use it.
- If there are some external functions, the library should be deployed into some address. Finally, the bytecode calling the library should be linked.

The following is only needed if your codebase uses libraries that need to be linked. However, if you need to use libraries that needed to be deployed (and the bytecode needs to be linked), then you will need this tutorial.

## Example code

For this tutorial, we will use [the metacoin example](https://github.com/truffle-box/metacoin-box). Let's start compiling it:

```
$ git clone https://github.com/truffle-box/metacoin-box
$ cd metacoin-box
$ npm i
```

## Deploying libraries

Libraries are contracts that need to be deployed first. Fortunately, Echidna allows us to do that easily, using the `deployContracts` option. In the metacoin example, we can use:

```yaml
deployContracts: [["0x1f", "ConvertLib"]]
```

The address where the library should be deployed is arbitrary, but it should be the same as the one in the used during the linking process.

## Linking libraries

Before a contract can use a deployed library, its bytecode requires to be linked. This procedure requries to replace a particular string place holder
in the bytecode by the address of the deployed library. Normally, either solc or the compilation framework (e.g. truffle) will take care of this.
However, in our case, we will use `crytic-compile`, since it is easier to handle all cases from different frameworks just adding one new argument
to pass to `crytic-compile` from Echidna:

```yaml
cryticArgs: ["--compile-libraries=(ConvertLib,0x1f)"]
```

Going back to the example, if we have both config options in a single config file (`echidna.yaml`), we can run the metacoin contract 
in `exploration` mode:

```
$ echidna . --test-mode exploration --corpus-dir corpus --contract MetaCoin --config echidna.yaml
```

We can use the coverage report to verify that function using the library (`getBalanceInEth`) is not reverting:

```
 28 | *   |     function getBalanceInEth(address addr) public view returns(uint){
 29 | *   |             return ConvertLib.convert(getBalance(addr),2);
 30 |     |     }
```

However, the code of the library itself will not have their coverage displayed correctly:

```
 6 |     | library ConvertLib{
 7 |     |     function convert(uint amount, uint conversionRate) public pure returns (uint convertedAmount)
 8 |     |     {
 9 |     |             return amount * conversionRate;
10 |     |     }
11 |     | }
```

This is caused by the usage of `delegatecall` to execute contract code and [unfortunately we do not have a workaround for it right now](https://github.com/crytic/echidna/issues/1042).

## Summary

Working with libraries in Echidna is supported. It involves to deploy the library to a particular address using `deployContracts` and then asking `crytic-compile` to link the bytecode with the same address using `--compile-libraries` command line.
