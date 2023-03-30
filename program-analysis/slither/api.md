## API Basics

Slither has an API that lets you explore basic attributes of the contract and its functions.

To load a codebase:

```python
from slither import Slither
slither = Slither('/path/to/project')

```

### Exploring contracts and functions

A `Slither` object has:

- `contracts (list(Contract)`: list of contracts
- `contracts_derived (list(Contract)`: list of contracts that are not inherited by another contract (subset of contracts)
- `get_contract_from_name (str)`: Return a list of contract matching the name

A `Contract` object has:

- `name (str)`: Name of the contract
- `functions (list(Function))`: List of functions
- `modifiers (list(Modifier))`: List of functions
- `all_functions_called (list(Function/Modifier))`: List of all the internal functions reachable by the contract
- `inheritance (list(Contract))`: List of inherited contracts
- `get_function_from_signature (str)`: Return a Function from its signature
- `get_modifier_from_signature (str)`: Return a Modifier from its signature
- `get_state_variable_from_name (str)`: Return a StateVariable from its name

A `Function` or a `Modifier` object has:

- `name (str)`: Name of the function
- `contract (contract)`: the contract where the function is declared
- `nodes (list(Node))`: List of the nodes composing the CFG of the function/modifier
- `entry_point (Node)`: Entry point of the CFG
- `variables_read (list(Variable))`: List of variables read
- `variables_written (list(Variable))`: List of variables written
- `state_variables_read (list(StateVariable))`: List of state variables read (subset of variables`read)
- `state_variables_written (list(StateVariable))`: List of state variables written (subset of variables`written)

### Example: Print Basic Information

[print_basic_information.py](https://github.com/crytic/building-secure-contracts/tree/master/program-analysis/slither/examples/print_basic_information.py) shows how to print basic information about a project.
