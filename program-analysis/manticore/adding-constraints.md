# Adding Constraints

**Table of contents:**

- [Introduction](#introduction)
- [Operators](#Operators)
- [Constraints](#constraints)
- [Checking Constraint](#checking-constraint)
- [Summary: Adding Constraints](#summary-adding-constraints)

## Introduction

We will see how to constrain the exploration. We will make the assumption that the
documentation of `f()` states that the function is never called with `a == 65`, so any bug with `a == 65` is not a real bug. The target is still the following smart contract (*[examples/example.sol](./examples/example.sol)*):

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

## Operators

The [Operators](https://github.com/trailofbits/manticore/blob/master/manticore/core/smtlib/operators.py) module facilitates the manipulation of constraints, among other it provides:

- Operators.AND,
- Operators.OR,
- Operators.UGT (unsigned greater than),
- Operators.UGE (unsigned greater than or equal to),
- Operators.ULT (unsigned lower than),
- Operators.ULE (unsigned lower than or equal to).

To import the module use the following:

```python3
from manticore.core.smtlib import Operators
```

`Operators.CONCAT` is used to concatenate an array to a value. For example, the return_data of a transaction needs to be changed to a value to be checked against another value:

```python3
last_return = Operators.CONCAT(256, *last_return)
```


## Constraints

You can use constraints globally or for a specific state.

### Global constraint

Use `m.constrain(constraint)` to add a global cosntraint.
For example, you can call a contract from a symbolic address, and restraint this address to be specific values:

```python3
symbolic_address = m.make_symbolic_value()
m.constraint(Operators.OR(symbolic == 0x41, symbolic_address == 0x42))
m.transaction(caller=user_account,
              address=contract_account,
              data=m.make_symbolic_buffer(320),
              value=0)
```

### State constraint

Use [state.constrain(constraint)](https://manticore.readthedocs.io/en/latest/api.html?highlight=operator#manticore.core.state.StateBase.constrain) to add a constraint to a specific state
It can be used to constrain the state after its exploration to check some property on it.

## Checking Constraint

Use `solver.check(state.constraints)` to know if a constraint is still feasible. 
For example, the following will constraint  symbolic_value to be different from 65 and check if the state is still feasible:

```python3
state.constrain(symbolic_var != 65)
if solver.check(state.constraints):
    # state is feasible
```

## Summary: Adding Constraints

Adding constraint to the previous code, we obtain:

```python3
from manticore.ethereum import ManticoreEVM
from manticore.core.smtlib.solver import Z3Solver

solver = Z3Solver.instance()

m = ManticoreEVM()

with open("example.sol") as f:
    source_code = f.read()

user_account = m.create_account(balance=1*10**18)
contract_account = m.solidity_create_contract(source_code, owner=user_account)

symbolic_var = m.make_symbolic_value()
contract_account.f(symbolic_var)

no_bug_found = True

## Check if an execution ends with a REVERT or INVALID
for state in m.terminated_states:
    last_tx = state.platform.transactions[-1]
    if last_tx.result in ['REVERT', 'INVALID']:
        # we do not consider the path were a == 65
        condition = symbolic_var != 65
        if m.generate_testcase(state, name="BugFound", only_if=condition):
            print(f'Bug found, results are in {m.workspace}')
            no_bug_found = False

if no_bug_found:
    print(f'No bug found')
```

All the code above you can find into the [examples/example_constraint.py](./examples/example_constraint.py)

The next step is to follow the [exercises](./exercises.md).
