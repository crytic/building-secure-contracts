# Finding Throwing Paths

**Table of Contents:**

- [Finding Throwing Paths](#finding-throwing-paths)
  - [Introduction](#introduction)
  - [Using State Information](#using-state-information)
  - [Generating Test Cases](#generating-test-cases)
  - [Summary](#summary)
  - [Summary: Finding Throwing Paths](#summary-finding-throwing-paths)

## Introduction

We will now improve [the previous example](running-under-manticore.md) and generate specific inputs for paths raising an exception in `f()`. The target is still the following smart contract ([example.sol](https://github.com/crytic/building-secure-contracts/tree/master/program-analysis/manticore/examples/example.sol)):

```solidity
pragma solidity >=0.4.24 <0.6.0;

contract Simple {
    function f(uint256 a) public payable {
        if (a == 65) {
            revert();
        }
    }
}
```

## Using State Information

Each executed path has its own blockchain state. A state is either ready or killed, meaning that it reaches a THROW or REVERT instruction:

- [m.ready_states](https://manticore.readthedocs.io/en/latest/states.html#accessing): the list of states that are ready (they did not execute a REVERT/INVALID)
- [m.killed_states](https://manticore.readthedocs.io/en/latest/states.html#accessings): the list of killed states (they did execute a REVERT/INVALID)
- [m.all_states](https://manticore.readthedocs.io/en/latest/states.html#accessings): all the states

```python3
for state in m.all_states:
    # do something with state
```

You can access information about a state. For example:

- `state.platform.get_balance(account.address)`: the balance of the account
- `state.platform.transactions`: the list of transactions
- `state.platform.transactions[-1].return_data`: the data returned by the last transaction

The data returned by the last transaction is an array, which can be converted to a value with ABI.deserialize. For example:

```python
data = state.platform.transactions[0].return_data
data = ABI.deserialize("uint256", data)
```

## Generating Test Cases

Use [m.generate_testcase(state, name)](https://github.com/trailofbits/manticore/blob/dc8c3c822bbd50adabe50cafef38457505c0bc7b/manticore/ethereum/manticore.py#L1572) to generate test cases:

```python3
m.generate_testcase(state, 'BugFound')
```

## Summary

- You can iterate over the states with m.all_states
- `state.platform.get_balance(account.address)` returns the account's balance
- `state.platform.transactions` returns the list of transactions
- `transaction.return_data` is the data returned
- `m.generate_testcase(state, name)` generates inputs for the state

## Summary: Finding Throwing Paths

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

You can find all the code above in the [example_throw.py](https://github.com/crytic/building-secure-contracts/tree/master/program-analysis/manticore/examples/example_throw.py) file.

The next step is to [add constraints](./adding-constraints.md) to the state.

_Note: We could have generated a much simpler script since all the states returned by terminated_state have REVERT or INVALID in their result. This example was only meant to demonstrate how to manipulate the API._
