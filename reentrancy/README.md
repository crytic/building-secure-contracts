# Re-entrancy

## Principle
- A state variable is changed after a call to `send` / `call.value`
- The attacker uses the fallback function to execute again the vulnerable function before the state variable are changed

## Attack
See `RentrancyExploit.sol` to exploit the contract.

## Known exploit
[DAO](http://hackingdistributed.com/2016/06/18/analysis-of-the-dao-exploit/)
