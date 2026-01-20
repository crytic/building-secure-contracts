# Cross-Chain Bridge Vulnerability: Permanent Locking of Funds Using `transfer()`

In cross-chain bridging, users often deposit tokens or ETH into a contract on one chain (e.g., Ethereum Layer 1) so that a corresponding representation can be minted on another chain (e.g., an L2 or sidechain). Eventually, users may wish to **redeem** or **withdraw** their tokens back to the original chain. However, some bridge implementations rely on the Solidity `transfer()` method when returning ETH to users. This can inadvertently lock funds **forever** if the recipient is a contract requiring more than 2300 gas in its `receive()` or `fallback()` function.

---

## How This Affects Cross-Chain Bridges

1. **Bridging and Redemption**  
   - In a typical cross-chain setup, a user sends ETH to a bridge contract on L1.  
   - After bridging, they might later request to withdraw or redeem that ETH back from the bridge.

2. **Using `transfer()` in the Bridge**  
   - The bridge tries to finalize the redemption by `transfer()`-ing the user’s ETH back.  
   - If that user’s address is actually a contract—like a multisig wallet or a DeFi protocol—that needs more than 2300 gas in its `fallback()`/`receive()`, the withdrawal fails.  
   - The bridging contract’s redemption process **reverts**, and the user cannot retrieve their ETH.

3. **Result: Funds Stuck in the Bridge**  
   - Because no other address is authorized to claim the same withdrawal, the ETH remains locked in the bridging contract.  
   - Future attempts to redeem the same balance also fail unless the code is modified or the bridging logic is upgraded (if at all possible).

---

## Example: Bridge Withdrawals That Fail for Contract Addresses

In this simplified `finalizeWithdrawal` function, the bridge tries to return ETH to the user (who might be a contract) using `transfer()`. The low gas stipend can cause a revert if the recipient’s fallback logic requires more gas.

```solidity
    // Called after a user has claimed tokens on L2 and wants to unlock them on L1
    function finalizeWithdrawal() external {
        require(canWithdraw[msg.sender], "No withdrawal available");
        uint256 amount = balances[msg.sender];
        require(amount > 0, "Nothing to withdraw");
        
        balances[msg.sender] = 0;

        // Vulnerable step: Using transfer() to push ETH
        // If msg.sender is a contract that needs >2300 gas, this will revert
        payable(msg.sender).transfer(amount);

   
        balances[msg.sender] = 0;
        canWithdraw[msg.sender] = false;
    }

```

Suppose a cross-chain bridge uses a queue-based redemption process:

1. **User Deposits ETH**  
   - Alice sends 10 ETH from L1 to the Bridge contract to mint a wrapped token on L2.

2. **Redemption Requested**  
   - Later, Alice wants to redeem her 10 ETH back to L1.  
   - She provides her **multisig** wallet address, which is stored in the bridge contract as the recipient.

3. **Bridge Attempts `transfer()`**  
   - After a cooldown or waiting period, the bridge finalizes the redemption by doing:
     ```solidity
     payable(msg.sender).transfer(amount);
     ```
   - However, the multisig’s `fallback()` requires more gas than `transfer()` provides (only 2300).

4. **Transaction Reverts**  
   - Since the multisig contract can’t execute its logic with 2300 gas, the transaction fails.  
   - The bridging contract reverts the withdrawal, leaving the 10 ETH stuck in the bridge’s custody.

5. **Assets Locked Forever**  
   - No alternative address can claim these funds, and Alice can’t modify her multisig to reduce gas usage.  
   - The 10 ETH remains trapped in the bridge contract indefinitely.

---


## Mitigations

1. **Use `call` Instead of `transfer()`**  
   - A safer approach is:
     ```solidity
     (bool success, ) = payable(recipient).call{value: amount}("");
     require(success, "ETH transfer failed");
     ```
   - `call` can forward more gas, preventing the out-of-gas revert scenario. Make sure precautions are made against reentrancy.

2. **Adopt Pull-Based Withdrawals**  
   - Instead of pushing ETH automatically, let recipients **pull** their funds.  
   - If a contract needs more gas, it can handle the withdrawal logic internally on its own terms.


By using more flexible methods to send ETH and accommodating higher gas requirements, cross-chain bridges can avoid permanently freezing user funds—particularly for advanced contract wallets on L1 or L2.
