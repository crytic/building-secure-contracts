# Front-Running Rebase Attack (Stepwise Jump in Rewards)

Some staking protocols periodically distribute rewards (often called a “rebase” or “batch reward”) to existing participants based on their share holdings. **Front-Running Rebase Attacks** occur when an attacker observes a large incoming reward, quickly deposits tokens to stake **just before** the reward arrives, and then withdraws after collecting a windfall. This results in **legitimate long-term stakers** losing a portion of the rewards they would otherwise have received.

---

## How It Works

1. **Normal Staking & Reward Distribution**  
   - Legitimate participants deposit tokens into a staking contract and receive proportional shares.  
   - Periodically (or whenever certain conditions are met), a reward is added to the staking contract. The contract’s total assets increase, inflating the value of each share.

2. **Attacker’s Timing**  
   - By monitoring mempool transactions or the protocol’s on-chain signals, an attacker can detect when a reward is about to arrive.  
   - Right **before** the reward hits the contract, the attacker deposits an amount to mint new shares at the **pre-reward** ratio.

3. **Rebase Event**  
   - A large reward is then deposited into the staking contract, boosting `totalAssets`.  
   - The attacker’s newly minted shares appreciate significantly, despite having staked only moments before.

4. **Immediate Withdrawal**  
   - The attacker quickly redeems their shares, claiming an outsized portion of the newly added reward.  
   - Long-term stakers who were in the pool beforehand see their rewards diluted by the attacker’s late deposit.

---

## Attack Impact on Legitimate Stakers

- **Diluted Rewards**  
  The reward that long-term stakers expect to share among themselves is partially diverted to the attacker.  
- **Reduced Incentive to Stake Long-Term**  
  Honest users who stake for extended periods find their earnings siphoned off by last-moment depositors.  
- **Increased Volatility**  
  Large, last-minute deposits before known rebase events create sudden swings in share distribution.

---

## Example of a Vulnerable Staking Contract

Below is a simplified example in which the contract periodically receives a reward (via the `receiveReward()` function). The attacker can watch for this call, deposit just prior, and then withdraw afterward to reap unearned gains.

```solidity
    function receiveReward(uint256 rewardAmount) external {
        // e.g., this might be called by an external contract or admin
        bool success = stakingToken.transferFrom(msg.sender, address(this), rewardAmount);
        require(success, "Reward transfer failed");

        emit RewardReceived(rewardAmount);
        // Notice: No new shares are minted. Existing shares are effectively more valuable.
    }
```

## Mitigation 

Deposit Lock / Vesting: Impose a lock-up period for deposits. Users who just deposited cannot withdraw until after a certain time or after the next reward cycle passes.This ensures that someone who arrives right before the reward can’t immediately exit.

Time-Weighted Rewards: Distribute rewards based on time staked rather than just instantaneous share balances.
Users who stake longer receive proportionally more, preventing short-term entrants from siphoning an outsized portion.
