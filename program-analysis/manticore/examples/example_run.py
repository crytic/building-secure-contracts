import os
from manticore.ethereum import ManticoreEVM

m = ManticoreEVM()
filename = os.path.join(os.path.dirname(os.path.realpath(__file__)), 'example.sol')

# Needs enough balance to pay for the gas of the initialization
user_account = m.create_account(balance=10**10)
with open(filename) as f:
    contract_account = m.solidity_create_contract(f, owner=user_account)

symbolic_var = m.make_symbolic_value()
contract_account.f(symbolic_var)

print("Results are in {}".format(m.workspace))
m.finalize() # stop the exploration
