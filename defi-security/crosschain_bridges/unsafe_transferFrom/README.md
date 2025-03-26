# Missing Revert on Failed Token Transfers in Bridges

When users deposit tokens into a cross-chain bridge, the typical process involves calling a token’s `transferFrom` function to move the user’s tokens into the bridge contract. The bridge then updates its internal records to reflect a successful deposit (e.g., incrementing a `balances[msg.sender]`). However, **not all tokens revert** upon transfer failure. Some tokens only return a boolean `false` without reverting the transaction. If a contract **ignores** this return value and assumes success, it can create a **false deposit** scenario where the user’s balance is updated even though **no tokens were actually transferred**.

## Why It Happens
- **Non-Reverting Tokens**  
  Several tokens (like **BAT**, **HT**, **cUSDC**, **ZRX**) do **not** revert if `transferFrom` fails (e.g., due to insufficient funds).
- **Bridge Assumes Success**  
  The bridging contract might assume that if the call didn’t revert, the tokens were deposited successfully—never checking the boolean return value.
- **Incorrect Balance Accounting**  
  As a result, the bridge increments the user’s deposit balance even though **no tokens** arrived in the bridge contract.

## Example: Vulnerable Bridge Deposit

```solidity
    function deposit(address token, uint256 amount) external {
        // Vulnerable approach: ignoring the transferFrom's return value
        IERC20NonReverting(token).transferFrom(msg.sender, address(this), amount);

        // Contract assumes deposit succeeded, updates user balance
        deposits[token][msg.sender] += amount;
    }

```

## Mitigation

Use safeTransferFrom. There are libraries that provide safe variants of transferFrom that revert on failure, eliminating silent failures.
