# Adding Constraints

**Table of contents:**

- [Adding Constraints](#adding-constraints)
  - [Introduction](#introduction)
  - [Operators](#operators)
  - [Constraints](#constraints)
    - [Global constraint](#global-constraint)
    - [State constraint](#state-constraint)
  - [Checking Constraint](#checking-constraint)
  - [Summary: Adding Constraints](#summary-adding-constraints)

## Introduction

We will explore how to limit the exploration by adding constraints. Assuming the documentation of `f()` states that the function is never called with `a == 65`, any bug with `a == 65` is not considered a real bug. Our target is the following smart contract ([example.sol](https://github.com/crytic/building-secure-contracts/tree/master/program-analysis/manticore/examples/example.sol)):

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

## Operators

The [Operators](https://github.com/trailofbits/manticore/blob/master/manticore/core/smtlib/operators.py) module enables constraint manipulation and provides various operations, such as:

- Operators.AND,
- Operators.OR,
- Operators.UGT (unsigned greater than),
- Operators.UGE (unsigned greater than or equal to),
- Operators.ULT (unsigned lower than),
- Operators.ULE (unsigned lower than or equal to).

To import the module, use the following:

```python3
from manticore.core.smtlib import Operators
```

`Operators.CONCAT` can be used to concatenate an array to a value. For instance, the return_data of a transaction needs to be converted to a value before checking it against another value:

```python3
last_return = Operators.CONCAT(256, *last_return)
```

## Constraints

Constraints can be applied globally or to a specific state.

### Global constraint

To add a global constraint, use `m.constrain(constraint)`. For example, you can call a contract from a symbolic address and limit this address to specific values:

```python3
symbolic_address = m.make_symbolic_value()
m.constraint(Operators.OR(symbolic == 0x41, symbolic_address == 0x42))
m.transaction(caller=user_account,
              address=contract_account,
              data=m.make_symbolic_buffer(320),
              value=0)
```

### State constraint

To add a constraint to a specific state, use [`state.constrain(constraint)`](https://manticore.readthedocs.io/en/latest/states.html?highlight=statebase#manticore.core.state.StateBase.constrain). It can be employed to constrain the state after its exploration in order to check properties on it.

## Checking Constraint

`solver.check(state.constraints)` can be used to determine if a constraint is still feasible. For instance, the following code constrains `symbolic_value` to be different from 65 and checks if the state is still feasible:

```python3
state.constrain(symbolic_var != 65)
if solver.check(state.constraints):
    # state is feasible
```

## Summary: Adding Constraints

By incorporating constraints into the previous code, we obtain:

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

The complete code can be found in [example_constraint.py](https://github.com/crytic/building-secure-contracts/tree/master/program-analysis/manticore/examples/example_constraint.py).

The next step is to follow the [exercises](./exercises).
