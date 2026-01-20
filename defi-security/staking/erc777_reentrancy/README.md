# General Considerations for ERC777 Reentrancy Vulnerabilities

ERC777 introduces **hooks**—a mechanism allowing recipients to register a function called automatically when they receive tokens. This added flexibility also creates a **reentrancy risk**, especially if a contract sends ERC777 tokens without carefully updating its state beforehand. Attackers can exploit these hooks to reenter vulnerable contract functions, potentially draining assets such as rewards or staked tokens.

---

## How ERC777 Reentrancy Arises

1. **Hooks on Transfer**  
   - When an ERC777 token is transferred, the recipient can register a “tokensReceived” hook.  
   - If the sending contract (e.g., a staking or reward contract) invokes `transfer` on an ERC777 token, the recipient’s hook is triggered during the transfer process.

2. **Reentrant Calls**  
   - If the contract **does not** follow safe practices (like the checks-effects-interactions pattern), the hook can re-enter the contract’s state-changing functions.  
   - For example, an attacker can repeatedly claim rewards if the contract updates internal balances **after** transferring the tokens.

3. **Multiple Claims or Withdrawals**  
   - By reentering, an attacker could call the same function that distributed rewards multiple times in a single transaction, or manipulate other logic (e.g., share calculations, deposit/withdraw flows).

---

## Example: Vulnerable `claimRewards` Function

Consider a staking contract that uses ERC777 tokens for distributing rewards. Below is a simplified version of how a reentrancy hole might appear:

```solidity
function claimRewards(address user, IERC20[] memory _rewardTokens) external {
    for (uint8 i = 0; i < _rewardTokens.length; i++) {
        uint256 rewardAmount = accruedRewards[user][_rewardTokens[i]];

        if (rewardAmount == 0) revert("Zero rewards");

        // Vulnerability: Transfer occurs before resetting accruedRewards
        _rewardTokens[i].transfer(user, rewardAmount);

        // The reward is reset only AFTER sending tokens
        // Attackers can reenter at this point if _rewardTokens[i] is ERC777
        accruedRewards[user][_rewardTokens[i]] = 0;

        emit RewardsClaimed(user, _rewardTokens[i], rewardAmount);
    }
}
```

## Mitigations

Use the Checks-Effects-Interactions Pattern. Update internal state before performing any external calls (like an ERC777 transfer).
For example:
```
uint256 rewardAmount = accruedRewards[user][token];
accruedRewards[user][token] = 0; // clear first
token.transfer(user, rewardAmount); // then transfer
```

Or use Reentrancy Guards. ReentrancyGuard modifiers can prevent nested calls to the same function.
