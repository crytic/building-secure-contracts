# Rugability from a Poorly Implemented `recoverERC20` in Staking Contracts

Many staking contracts include a **recoverERC20** function, allowing the owner to retrieve tokens accidentally sent to the contract. If not carefully designed, this feature can be abused for a **rug pull**, where the owner can withdraw critical assets—such as reward tokens—at will. An even trickier scenario arises when certain tokens have **multiple entry points** or “double addresses,” enabling an owner to bypass naive checks and drain staked or reward tokens by referencing an alternate address for the same token.

---

## How the Vulnerability Arises

1. **Recover Function Without Restrictions**  
   - A simple `recoverERC20` might allow the contract owner to retrieve **any** ERC20 token from the contract, including staking or reward tokens.  
   - Example:

   ```solidity
   function recoverERC20(address token, uint256 amount) external onlyOwner {
       // Vulnerable: no check against the token in use for staking or rewards
       IERC20(token).transfer(msg.sender, amount);
   }
   
2. **Insufficient Checks**

Some developers add a rudimentary check: require(token != address(stakingToken)) to prevent recovering the staked token.

```solidity 
   function recoverERC20(address token, uint256 amount) external onlyOwner {
       require(token != address(stakingToken))
       IERC20(token).transfer(msg.sender, amount);
   }
```
However, if a token has multiple contract addresses or a “double entry point” design, a cunning owner (or attacker) can pass a different address that references the same underlying token.
This effectively evades the naive token != stakedToken comparison.

Because recoverERC20 can be called at any time by the owner, the entire reward pool or staked tokens can be siphoned out without user consent.

## Mitigation Strategies

Maintain a whitelist or blacklist of token addresses. Ensure the staked token, reward token, or any known “wrapper” addresses cannot be recovered.

Or by entirely removing the ability to recover ERC20 tokens, developers can eliminate a major rug pull vector and maintain user confidence in the staking platform.