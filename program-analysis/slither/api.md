## API Basics

Slither has an API that allows you to explore basic attributes of contracts and their functions.

To load a codebase:

```python
from slither import Slither
slither = Slither('/path/to/project')
```

### Exploring Contracts and Functions

A `Slither` object has:

- `contracts (list(Contract))`: A list of contracts
- `contracts_derived (list(Contract))`: A list of contracts that are not inherited by another contract (a subset of contracts)
- `get_contract_from_name (str)`: Returns a list of contracts matching the name

A `Contract` object has:

- `name (str)`: The name of the contract
- `functions (list(Function))`: A list of functions
- `modifiers (list(Modifier))`: A list of modifiers
- `all_functions_called (list(Function/Modifier))`: A list of all internal functions reachable by the contract
- `inheritance (list(Contract))`: A list of inherited contracts
- `get_function_from_signature (str)`: Returns a Function from its signature
- `get_modifier_from_signature (str)`: Returns a Modifier from its signature
- `get_state_variable_from_name (str)`: Returns a StateVariable from its name

A `Function` or a `Modifier` object has:

- `name (str)`: The name of the function
- `contract (contract)`: The contract where the function is declared
- `nodes (list(Node))`: A list of nodes composing the CFG of the function/modifier
- `entry_point (Node)`: The entry point of the CFG
- `variables_read (list(Variable))`: A list of variables read
- `variables_written (list(Variable))`: A list of variables written
- `state_variables_read (list(StateVariable))`: A list of state variables read (a subset of `variables_read`)
- `state_variables_written (list(StateVariable))`: A list of state variables written (a subset of `variables_written`)

### Example: Print Basic Information

[print_basic_information.py](https://github.com/crytic/building-secure-contracts/tree/master/program-analysis/slither/examples/print_basic_information.py) demonstrates how to print basic information about a project.
