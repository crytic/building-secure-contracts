# Re-entrancy
A state variable is changed after a contract uses `call.value`. The attacker uses the fallback function to
execute the vulnerable function again before the state variable is changed.

## Attack Scenarios
- A contract that holds a map of account balances allows users to call a `withdraw` function. However,
`withdraw` calls `send` which transfers control to the calling contract, but doesn't decrease their
balance until after `send` has finished executing. The attacker can then repeatedly withdraw money
that they do not have.

## Mitigations

- Avoid use of `call.value`

## Examples
[DAO](http://hackingdistributed.com/2016/06/18/analysis-of-the-dao-exploit/)

## References