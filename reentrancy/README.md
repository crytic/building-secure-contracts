# Re-entrancy
A state variable is changed after a contract uses `call.value`. The attacker uses
[a fallback function](ReentrancyExploit.sol#L26-L33)—which is automatically executed after
Ether is transferred from the targeted contract—to execute the vulnerable function again, *before* the
state variable is changed.

## Attack Scenarios
- A contract that holds a map of account balances allows users to call a `withdraw` function. However,
`withdraw` calls `send` which transfers control to the calling contract, but doesn't decrease their
balance until after `send` has finished executing. The attacker can then repeatedly withdraw money
that they do not have.

## Mitigations

- Avoid use of `call.value`
- Update all bookkeeping state variables _before_ transferring execution to an external contract.

## Examples

- The [DAO](http://hackingdistributed.com/2016/06/18/analysis-of-the-dao-exploit/) hack
- The [SpankChain](https://medium.com/spankchain/we-got-spanked-what-we-know-so-far-d5ed3a0f38fe) hack
