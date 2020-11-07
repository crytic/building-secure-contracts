# Running under Manticore

**Table of contents:**

- [Introduction](#introduction)
- [Run a standalone exploration](#run-a-standalone-exploration)
- [Manipulate a smart contract through the API](#manipulate-a-smart-contract-through-the-api)
- [Summary: Running under Manticore](#summary-running-under-manticore)


## Introduction

We will see how to explore a smart contract with the Manticore API. The target is the following smart contract (*[examples/example.sol](./examples/example.sol)*):

```Solidity
pragma solidity >=0.4.24 <0.6.0;
contract Simple {
    function f(uint a) payable public{
        if (a == 65) {
            revert();
        }
    }
}
```

## Run a standalone exploration

You can run Manticore directly on the smart contract by the following command (`project` can be a Solidity File, or a project directory):

```bash
$ manticore project
```


You will get the output of testcases like this one (the order may change):

```
...
... m.c.manticore:INFO: Generated testcase No. 0 - STOP
... m.c.manticore:INFO: Generated testcase No. 1 - REVERT
... m.c.manticore:INFO: Generated testcase No. 2 - RETURN
... m.c.manticore:INFO: Generated testcase No. 3 - REVERT
... m.c.manticore:INFO: Generated testcase No. 4 - STOP
... m.c.manticore:INFO: Generated testcase No. 5 - REVERT
... m.c.manticore:INFO: Generated testcase No. 6 - REVERT
... m.c.manticore:INFO: Results in /home/ethsec/workshops/Automated Smart Contracts Audit - TruffleCon 2018/manticore/examples/mcore_t6vi6ij3
...
```

Without additional information, Manticore will explore the contract with new symbolic
transactions until it does not explore new paths on the contract. Manticore does not run new transactions after a failing one (e.g: after a revert).

Manticore will output the information in a `mcore_*` directory. Among other, you will find in this directory:

 - `global.summary`: coverage and compiler warnings
 - `test_XXXXX.summary`: coverage, last instruction, account balances per test case
 - `test_XXXXX.tx`: detailed list of transactions per test case

Here Manticore founds 7 test cases, which correspond to (the filename order may change):

|                  |    Transaction 0   |   Transaction 1   |  Transaction 2    | Result |
|:----------------:|:------------------:|:-----------------:|-------------------|:------:|
| **test_00000000.tx** | Contract  creation | f(!=65)           |  f(!=65)          | STOP |
| **test_00000001.tx** | Contract  creation | fallback function             |                   | REVERT |
| **test_00000002.tx** | Contract  creation |                   |                   | RETURN |
| **test_00000003.tx** | Contract  creation | f(65)             |                   | REVERT   |
| **test_00000004.tx** | Contract  creation | f(!=65)           |                   | STOP |
| **test_00000005.tx** | Contract  creation | f(!=65)           | f(65)             | REVERT   |
| **test_00000006.tx** | Contract  creation | f(!=65)           | fallback function             | REVERT   |

_Exploration summary f(!=65) denotes f called with any value different than 65._

As you can notice, Manticore generates an unique test case for every successful or reverted transaction.

Use the `--quick-mode` flag if you want fast code exploration (it disable bug detectors, gas computation, ...)


## Manipulate a smart contract through the API

This section describes details how to manipulate a smart contract through the Manticore Python API. You can create new file with python extension ```*.py``` and write the necessary code by adding the API commands (basics of which will be described below) into this file and then run it with the command ```$ python3 *.py```. Also you can execute the commands below directly into the python console, to run the console use the command ```$ python3```.

### Creating Accounts

The first thing you should do is to initiate a new blockchain with the following commands:

```python3
from manticore.ethereum import ManticoreEVM

m = ManticoreEVM()
```

A non-contract account is created using [m.create_account](https://manticore.readthedocs.io/en/latest/api.html#manticore.ethereum.ManticoreEVM.create_account):

```python3
user_account = m.create_account(balance=1 * 10**18)
```

A Solidity contract can be deployed using [m.solidity_create_contract](https://manticore.readthedocs.io/en/latest/api.html#manticore.ethereum.ManticoreEVM.solidity_create_contract):

```python3
source_code = '''
pragma solidity >=0.4.24 <0.6.0;
contract Simple {
    function f(uint a) payable public{
        if (a == 65) {
            revert();
        }
    }
}
'''
# Initiate the contract
contract_account = m.solidity_create_contract(source_code, owner=user_account)
```

#### Summary

- You can create user and contract accounts with [m.create_account](https://manticore.readthedocs.io/en/latest/api.html#manticore.ethereum.ManticoreEVM.create_account) and [m.solidity_create_contract](https://manticore.readthedocs.io/en/latest/api.html#manticore.ethereum.ManticoreEVM.solidity_create_contract.

### Executing transactions

Manticore supports two types of transaction:

- Raw transaction: all the functions are explored
- Named transaction: only one function is explored

#### Raw transaction

A raw transaction is executed using [m.transaction](https://manticore.readthedocs.io/en/latest/api.html#manticore.ethereum.ManticoreEVM.transaction):

```python3
m.transaction(caller=user_account,
              address=contract_account,
              data=data,
              value=value)
```

The caller, the address, the data, or the value of the transaction can be either concrete or symbolic:

- [m.make_symbolic_value](https://manticore.readthedocs.io/en/latest/api.html#manticore.ethereum.ManticoreEVM.make_symbolic_value) creates a symbolic value.
- [m.make_symbolic_buffer(size)](https://manticore.readthedocs.io/en/latest/api.html#manticore.ethereum.ManticoreEVM.make_symbolic_buffer) creates a symbolic byte array.

For example:

```python3
symbolic_value = m.make_symbolic_value()
symbolic_data = m.make_symbolic_buffer(320)
m.transaction(caller=user_account,
              address=contract_address,
              data=symbolic_data,
              value=symbolic_value)
```

If the data is symbolic, Manticore will explore all the functions of the contract during the transaction execution. It will be helpful to see the Fallback Function explanation in the [Hands on the Ethernaut CTF](https://blog.trailofbits.com/2017/11/06/hands-on-the-ethernaut-ctf/) article for understanding how the function selection works.

#### Named transaction

Functions can be executed through their name.
To execute `f(uint var)` with a symbolic value, from user_account, and with 0 ether, use:

```python3
symbolic_var = m.make_symbolic_value()
contract_account.f(symbolic_var, caller=user_account, value=0)
```

If `value` of the transaction is not specified, it is 0 by default.

#### Summary

- Arguments of a transaction can be concrete or symbolic
- A raw transaction will explore all the functions
- Function can be called by their name


### Workspace

`m.workspace` is the directory used as output directory for all the files generated:

```python3
print("Results are in {}".format(m.workspace))
```

### Terminate the Exploration

To stop the exploration use [m.finalize()](https://manticore.readthedocs.io/en/latest/api.html#manticore.ethereum.ManticoreEVM.finalize). No further transactions should be sent once this method is called and Manticore generates test cases for each of the path explored.

## Summary: Running under Manticore

Putting all the previous steps together, we obtain:

```python3
from manticore.ethereum import ManticoreEVM

m = ManticoreEVM()

with open('example.sol') as f:
    source_code = f.read()

user_account = m.create_account(balance=1*10**18)
contract_account = m.solidity_create_contract(source_code, owner=user_account)

symbolic_var = m.make_symbolic_value()
contract_account.f(symbolic_var)

print("Results are in {}".format(m.workspace))
m.finalize() # stop the exploration
```

All the code above you can find into the [examples/example_run.py](./examples/example_run.py)

The next step is to [accessing the paths](./getting-throwing-paths.md).
