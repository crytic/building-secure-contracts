# ERC777 Bridge Vulnerability: Reentrancy Attack in Token Accounting

Cross-chain bridges enable token transfers between different layers (e.g., L1 and L2). However, when these bridges support **ERC-777** tokens, their advanced callback hooks can introduce **reentrancy** vulnerabilities—allowing attackers to manipulate token accounting before the original transaction completes.

---

## Fee-on-Transfer Tokens

**Fee-on-transfer** tokens are tokens that automatically deduct a fee whenever they are transferred. As a result:

- The **sender** specifies an `amount` to send.
- The **receiver** ends up with a lesser amount (the difference is taken as a fee).
- The bridging contract cannot simply trust the `amount` passed to the `transfer` function.

Hence, bridges often rely on computing `balanceAfter - balanceBefore` to determine the **exact** amount that actually arrived in the contract. This practice accommodates fee-on-transfer tokens, but also opens up potential reentrancy risks when dealing with ERC-777 tokens if the contract is not safeguarded.

---

## How the Vulnerability Arises

1. **ERC-777 Callback Hooks**  
   - Unlike standard ERC-20 tokens, ERC-777 supports hooks via the ERC-1820 registry.  
   - Attackers can register a contract to be notified (`tokensToSend`) whenever a transfer occurs, creating an opening for reentrancy.

2. **Balance-Based Bridging Logic**  
   - Bridges measure `balanceBefore` and `balanceAfter` to handle fee-on-transfer tokens.  
   - If a malicious contract re-enters during the transfer, the contract may incorrectly calculate how many tokens were deposited.

3. **Lack of Reentrancy Protection**  
   - Without proper guards or a safe pattern, the bridge function can be invoked **twice** (or more) within a single flow, causing inaccurate state updates.

---
## Attack Scenario

1. **Attacker Registers a Malicious Sender Contract**  
   - The attacker sets their contract as an `ERC777TokensSender` in the ERC-1820 registry.

2. **Initial Bridge Call**  
   - The attacker calls `bridgeToken` with 500 tokens.  
   - The bridge records `balanceBefore = 0`, then initiates `safeTransferFrom`.

3. **Reentrancy During Callback**  
   - `tokensToSend` is triggered in the attacker’s contract, which **re-enters** `bridgeToken` to transfer another 500 tokens.  
   - Since the first call hasn’t updated state yet, the second call still sees `balanceBefore = 0`.

4. **Combined Transfers**  
   - By the time the original call finishes, `balanceAfter` is 1000 in the original call, but the logic credits 1500 tokens on L2 (500 from the reentrant call plus the erroneously calculated amount from the first call).

---

## Example Code (Vulnerable)

```solidity
function bridgeToken(address token, uint256 amount) external {
    uint256 balanceBefore = IERC20(token).balanceOf(address(this));

    // Transfer tokens from msg.sender to the bridge
    IERC20(token).safeTransferFrom(msg.sender, address(this), amount);

    uint256 balanceAfter = IERC20(token).balanceOf(address(this));
    uint256 bridgedAmount = balanceAfter - balanceBefore;
}
```

## Mitigations



Leverage mechanisms like ReentrancyGuard or similar logic that disallows nested calls to vulnerable functions.