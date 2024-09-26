from manticore.ethereum import ManticoreEVM

ETHER = 10**18

m = ManticoreEVM()

with open('example.sol') as f:
    source_code = f.read()

user_account = m.create_account(balance=1000*ETHER)
contract_account = m.solidity_create_contract(source_code,
                                              owner=user_account)

symbolic_var = m.make_symbolic_value()
contract_account.f(symbolic_var)

## Check if an execution ends with a REVERT or INVALID
for state in m.terminated_states:
    last_tx = state.platform.transactions[-1]
    if last_tx.result in ['REVERT', 'INVALID']:
        print('Throw found {}'.format(m.workspace))
        m.generate_testcase(state, 'ThrowFound')
