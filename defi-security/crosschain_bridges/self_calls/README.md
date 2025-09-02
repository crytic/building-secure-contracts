# Avoiding Privilege Escalation via Self-Calls in Cross-Chain Bridges

In many cross-chain bridge designs, certain contracts (often called “managers” or “governors”) hold **privileged roles**. These roles allow them to manage core operations like minting/burning tokens, updating trusted validators, or forwarding user transactions across chains. If these privileged contracts can be **invoked by user-controlled data**—especially in a way that allows **self-calls**—an attacker can craft malicious parameters that make the bridge invoke its own privileged functions without proper authorization checks.

---

## The Core Issue

1. **Arbitrary Call Data**  
   - The bridge contract receives arbitrary parameters (e.g., `toContract`, `method`, `args`) from user transactions or relayers.  
   - If these parameters aren’t adequately validated, the contract might call **itself** (or another sensitive contract) with escalated privileges.

2. **Privileged Self-Calls**  
   - Some cross-chain manager contracts can act as an owner or admin for other contracts in the same system.  
   - If the manager can be tricked into calling itself with special permissions (e.g., `owner` functions), it effectively bypasses normal access controls.

3. **Insufficient Checks**  
   - If the bridge only checks signature validity or message authenticity but **not** the actual function or contract being invoked, an attacker can slip in a call to update privileged roles, change deposit addresses, or seize funds.

---

# Example: The Poly Network Hack

On August 10, 2021, the Poly Network—an interoperability protocol linking multiple blockchains—suffered a major breach. By crafting **malicious call data**, the attacker was able to convince the protocol’s **cross-chain manager** to call privileged functions **on itself**, granting the attacker elevated permissions. This resulted in the theft of hundreds of millions of dollars in various cryptocurrencies across Ethereum, BSC, and Polygon.

## Mitigation

Strict Validation of Target and Methods. Deny self-calls to privileged functions unless explicitly intended. Only allow a whitelisted set of external contracts and method signatures to be invoked.

