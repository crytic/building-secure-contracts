from manticore.ethereum import ManticoreEVM
from manticore.core.smtlib import Operators, solver
from manticore.ethereum.abi import ABI

ETHER = 10**18

m = ManticoreEVM() # initiate the blockchain

# Generate the accounts
user_account = m.create_account(balance=1000*ETHER)
with open('overflow.sol') as f:
    contract_account = m.solidity_create_contract(f, owner=user_account)

#First add won't overflow uint256 representation
value_0 = m.make_symbolic_value()
contract_account.add(value_0, caller=user_account)
#Potential overflow
value_1 = m.make_symbolic_value()
contract_account.add(value_1, caller=user_account)
contract_account.sellerBalance(caller=user_account)








