# Exercice 2 : Arithmetic on multi transactions

Use Manticore to find if an overflow is possible in Overflow.add. Propose a fix of the contract, and test your fix using your Manticore script.

## Proposed scenario

Follow the pattern initilization, exploration and property for the script.

### Initialization

- Create one user account
- Create the contract account

## Exploration

- Call two times `add` with two symbolic values
- Call `sellerBalance()`

## Property

- Check if it is possible for the value returned by sellerBalance() to be lower than the first input.

## Hints:

- The value returned by the last transaction can be accessed through:

```python
state.platform.transactions[-1].return_data
```

- The data returned needs to be deserialized:

```python
data = ABI.deserialize("uint", data)
```

- You can use the template proposed in [exercise2/template.sol](./exercise2/template.sol)

### Solution

[exercise2/solution.py](./exercise2/solution.py).
