from manticore.ethereum import ManticoreEVM, ABI
from manticore.core.smtlib import Operators, solver

###### Initialization ######

ETHER = 10**18

m = ManticoreEVM()
with open('my_token.sol') as f:
    source_code = f.read()

# Create one user account
# And deploy the contract
user_account = m.create_account(balance=1000*ETHER)
contract_account = m.solidity_create_contract(source_code, owner=user_account, balance=0)

###### Exploration ######

# - Call balances[user]
# - Call transfer with symbolic values
# - Call balances[user]
# Later we will compare the result of the first call to balances to the second
contract_account.balances(user_account)

symbolic_val = m.make_symbolic_value()
symbolic_to = m.make_symbolic_value()
# Transfer is called with symbolic values
# Manticore will fork and create state at each condition executed
contract_account.transfer(symbolic_to, symbolic_val)

contract_account.balances(user_account)

# Check of properties ######

bug_found = False
# Explore all the forks
for state in m.ready_states:

    # state.plateform.transactions returns the list of transactions
    # state.plateform.transactions[0] is the contract creation
    # state.plateform.transactions[1] is the first transaction
    # state.plateform.transactions[-1] is the last transaction

    balance_before = state.platform.transactions[1].return_data
    balance_before = ABI.deserialize("uint", balance_before)

    balance_after = state.platform.transactions[-1].return_data
    balance_after = ABI.deserialize("uint", balance_after)

    # Check if it is possible to have balance_after > balance_before
    condition = Operators.UGT(balance_after, balance_before)
    if m.generate_testcase(state, name="BugFound", only_if=condition):
        print("Bug found! see {}".format(m.workspace))
        bug_found = True

if not bug_found:
    print('No bug were found')