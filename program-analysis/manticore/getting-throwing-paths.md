# Getting Throwing Path

**Table of contents:**

- [Introduction](#introduction)
- [Using state information](#using-state-information)
- [How to generate testcase](#how-to-generate-testcase)
- [Summary: Getting Throwing Path](#summary-getting-throwing-path)


## Introduction

We will now improve [the previous example](running-under-manticore.md) and generate specific inputs for the paths raising an exception in `f()`. The target is still the following smart contract (*[examples/example.sol](./examples/example.sol)*):

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

## Using state information

Each path executed has its state of the blockchain. A state is either ready or it is killed, meaning that it reaches a THROW or REVERT instruction:

- [m.ready_states](https://manticore.readthedocs.io/en/latest/states.html#accessing): the list of states that are ready (they did not execute a REVERT/INVALID)
- [m.killed_states](https://manticore.readthedocs.io/en/latest/states.html#accessings): the list of states that are ready (they did not execute a REVERT/INVALID)
- [m.all_states](https://manticore.readthedocs.io/en/latest/states.html#accessings): all the states

```python3
for state in m.all_states:
    # do something with state
```

You can access state information. For example:

- `state.platform.get_balance(account.address)`: the balance of the account
- `state.platform.transactions`: the list of transactions
- `state.platform.transactions[-1].return_data`: the data returned by the last transaction

The data returned by the last transaction is an array, which can be converted to a value with ABI.deserialize, for example:

```python
data = state.platform.transactions[0].return_data
data = ABI.deserialize("uint", data)
```

## How to generate testcase

Use [m.generate_testcase(state, name)](https://manticore.readthedocs.io/en/latest/api.html#manticore.ethereum.ManticoreEVM.generate_testcase) to generate testcase:

```python3
m.generate_testcase(state, 'BugFound')
```

## Summary

- You can iterate over the state with m.all_states
- `state.platform.get_balance(account.address)` returns the account’s balance
- `state.platform.transactions` returns the list of transactions
- `transaction.return_data` is the data returned
- `m.generate_testcase(state, name)` generate inputs for the state

## Summary: Getting Throwing Path

```python3
from manticore.ethereum import ManticoreEVM

m = ManticoreEVM()

with open('example.sol') as f:
    source_code = f.read()

user_account = m.create_account(balance=1*10**18)
contract_account = m.solidity_create_contract(source_code, owner=user_account)

symbolic_var = m.make_symbolic_value()
contract_account.f(symbolic_var)

## Check if an execution ends with a REVERT or INVALID
for state in m.terminated_states:
    last_tx = state.platform.transactions[-1]
    if last_tx.result in ['REVERT', 'INVALID']:
        print('Throw found {}'.format(m.workspace))
        m.generate_testcase(state, 'ThrowFound')
```

All the code above you can find into the [examples/example_throw.py](./examples/example_throw.py)

The next step is to [add constraints](./adding-constraints.md) to the state.

*Note we could have generated a much simpler script, as all the states returned by terminated_state have REVERT or INVALID in their result: this example was only meant to demonstrate how to manipulate the API.*

