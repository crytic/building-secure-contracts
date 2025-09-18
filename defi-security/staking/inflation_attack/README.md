# First Depositor Inflation Attack with ERC20 Tokens

In some staking or liquidity pool contracts, the first depositor can gain a huge advantage if **no** tokens have been deposited yet (`totalShares == 0`). By combining **front-running** with a follow-up “donation” of tokens that **does not** mint additional shares, the attacker can inflate the total token balance without increasing `totalShares`. As a result, **subsequent depositors** receive virtually no shares for their deposits.

---

## The Attack Sequence

1. **First Depositor Spotting**  
   - A malicious user watches for a transaction indicating a new deposit into an empty pool.  
   - Before the honest user’s deposit is confirmed, the attacker quickly deposits **1 wei** (or some minimal amount) of the ERC20 token to become the actual first depositor.

2. **Minting Shares at 1:1**  
   - Because `totalShares == 0`, the staking contract mints shares equal to the deposited amount (e.g., 1 share for 1 token).  
   - Now the attacker holds **almost all** the existing shares (since nobody else deposited yet).

3. **Donating (Inflating) Tokens**  
   - Next, the attacker **directly transfers** a large number of tokens to the contract’s address (e.g., 100,000 tokens), **without** calling the deposit function.  
   - The contract’s token balance (`totalAssets`) is now huge, but `totalShares` remains the same (the donation didn’t mint new shares).

4. **Honest User’s Deposit**  
   - When the honest user’s deposit is finally mined, the pool calculates how many shares to mint using: ``` minted = (amount * totalShares) / (totalAssets);```
   - Since `totalAssets` is enormous, the ratio is tiny, resulting in **zero** shares minted.

5. **Attacker Gains**  
   - The attacker, owning  100% of the pool’s shares, can later **withdraw** to claim the all of the tokens, including those deposited by the honest user.

---

## Example of a Vulnerable Contract

Below is a simplified ERC20-based staking contract that illustrates how an attacker can exploit the first deposit and a subsequent “donation.” Note that this contract:

- Tracks total shares in `totalShares`.  
- Uses `balanceOf(address(this))` (the token balance in the contract) as `totalAssets`.  
- Does **not** handle direct transfers to the contract that inflate its balance without minting new shares.

```solidity
    function deposit(uint256 amount) external {
        require(amount > 0, "Deposit must be > 0");
        
        stakingToken.safeTransferFrom(msg.sender, address(this), amount);

        uint256 totalAssets = stakingToken.balanceOf(address(this)); // current token balance in the contract
        
        uint256 minted;
        if (totalShares == 0) {
            // First depositor: 1:1 ratio
            minted = amount;
        } else {

            minted = (amount * totalShares) / totalAssets;
        }

        sharesOf[msg.sender] += minted;
        totalShares += minted;

        emit Deposit(msg.sender, amount, minted);
    }

    function withdraw(uint256 shareAmount) external {
        require(shareAmount > 0, "Withdraw must be > 0");
        require(shareAmount <= sharesOf[msg.sender], "Not enough shares");

        uint256 totalAssets = stakingToken.balanceOf(address(this));

        uint256 withdrawAmount = (shareAmount * totalAssets) / totalShares;

        sharesOf[msg.sender] -= shareAmount;
        totalShares -= shareAmount;
        
        stakingToken.safeTransfer(msg.sender, withdrawAmount);

        emit Withdraw(msg.sender, withdrawAmount, shareAmount);
    }
```

## Mitigation

Seed the Pool at Deployment. Fund the contract with some initial tokens (ensuring totalShares != 0 from the start). This weakens the first depositor advantage.