from manticore.ethereum import ManticoreEVM
from manticore.ethereum.abi import ABI
from manticore.core.smtlib import Operators

ETHER = 10**18

m = ManticoreEVM() # initiate the blockchain
# Init
user_account = m.create_account(1*ETHER)
with open('token.sol', 'r') as f:
    contract_account = m.solidity_create_contract(f, owner=user_account)

# Exploration
tokens_amount = m.make_symbolic_value()
wei_amount = m.make_symbolic_value()

contract_account.is_valid_buy(tokens_amount, wei_amount)

# Property
for state in m.ready_states:

    condition = Operators.AND(wei_amount == 0, tokens_amount >= 1)

    if m.generate_testcase(state, name="BugFound", only_if=condition):
        print(f'Bug found, results are in {m.workspace}')









