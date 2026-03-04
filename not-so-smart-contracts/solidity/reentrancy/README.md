# Reentrancy

[The DAO](https://en.wikipedia.org/wiki/The_DAO_(organization)) experienced the most famous [hack](http://hackingdistributed.com/2016/06/18/analysis-of-the-dao-exploit/) in Ethereum's history which ultimately led to a contentious hardfork as funds were recovered on Ethereum but not on Ethereum Classic. This hack was one of the first recorded reentrancy attacks: A state variable was changed after sending ether to an external contract. The attacker uses [a fallback function](ReentrancyExploit.sol#L26-L33) (which is automatically executed after ether is transferred from the targeted contract) to execute the vulnerable function again, *before* the state variable is changed. As a result, they could repeatedly withdraw funds that they did not own.

Afterwards, solidity introduced `send` and `transfer` functions which only supply 2300 gas; enough to emit an Event but not enough to repeatedly call external contracts to perform the type of reentrancy that victimized The DAO. Reentrancy attacks triggered by simply sending ether are no longer feasible in the same way as it was for The DAO.

However, reentrancy attacked lived on via more complicated function calls. For example, [SpankChain's state channels experienced a reentrancy attack](https://medium.com/spankchain/we-got-spanked-what-we-know-so-far-d5ed3a0f38fe) due to their support for user-supplied tokens. The attacker supplied a modified ERC20 token with a `transfer` function that called back into the SpankChain state channel manager to repeatedly withdraw funds.

Notable, in both of these cases the exploited contract did not follow the [Check-Effects-Interaction pattern](https://docs.soliditylang.org/en/latest/security-considerations.html#use-the-checks-effects-interactions-pattern):
1. Check that the user-supplied parameters are valid eg that a withdrawing user has sufficient balance
2. Update accounting variables eg set the withdrawing user's balance to zero.
3. Send the user's withdrawal to their address.

If SpankChain updated the user's balance to zero before calling `transfer` on the token contract, then there would be nothing to withdraw when the token called back into the withdrawal method.

## Example

See the four different withdraw functions of [Reenterable](Reenterable.sol). The first one is vulnerable to reentrancy attacks by the [ReentrancyExploiter](ReentrancyExploiter.sol) but the other three are fixed in the three different ways described below.

## Mitigations

- Use the check-effects-interaction pattern: update all bookkeeping state variables **before** allowing an external contracts to execute.
- Use `send` or `transfer` to move ether to an external account, these only supply 2300 gas which is not enough to call back into the calling contract.
- Use a reentrancy guard on sensitive external functions. This acts as a mutex to ensure that a function can't be called again until it completely finishes executing the current call. [OpenZeppelin's ReentrancyGuard](https://docs.openzeppelin.com/contracts/4.x/api/security#ReentrancyGuard) provides a ready-made function modifier for this.

