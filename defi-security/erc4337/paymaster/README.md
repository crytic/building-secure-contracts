# ERC-4337 Paymaster and Signature Replay Vulnerabilities

When integrating **ERC-4337** (Account Abstraction) with **Paymasters**—contracts that sponsor gas for user operations (UserOps)—careful signature handling is essential. Improper validation can expose the Paymaster to **replay attacks** and **overpayment exploits**, undermining both the wallet’s and Paymaster’s security.

---

## 1. Paymaster Signature Replay (Cross-Chain Risk)

**Problem**: If a Paymaster’s signature over the UserOp does **not** include the `chainId` (or other chain-specific data) in its hashing scheme, an operation **may** be replayed on another chain with the same Paymaster signer. This is because the same UserOp data (including the Paymaster signature) could be valid across multiple chains if the addresses and verifying signer remain consistent.

### Impact

- **Cross-Chain Replay**: The user’s operation can be executed on multiple networks if the Paymaster’s signature does not distinguish chain contexts.  
- **Sponsorship Drain**: Attackers can repeatedly sponsor the same UserOp on different chains, draining Paymaster funds.

### Mitigation

- **Include `chainId` in the Signature Hash**  
  - Incorporate the current chain ID into `getHash` (or similar function) so that a signature from one chain **cannot** be valid on another.  


---

## 2. Missing Fields in Signed Data (tokenGasPrice)

**Problem**: When a user’s wallet refunds gas in ERC20 tokens, certain fields (e.g `tokenGasPrice`) must be included in the signed data to prevent tampering by the transaction submitter. If that field is **omitted** from the hash, an attacker can override the factor after the user has already signed, inflating their gas reimbursement and stealing user funds.

### Impact

- **Overpayment of Gas Refund**: The sponsor or user paying for gas in ERC20 tokens loses significantly more tokens than expected.  
- **Theft of Funds**: The attacker effectively “pays themselves” an inflated refund, draining the user’s account or the Paymaster’s balance.

### Mitigation

- **Include All Critical Fields in the Hash**  
  - The user’s signature must cover every parameter that affects payment, especially including token gas price.  

- **Validate Off-Chain**  
  - Signatures should represent the entire transaction, including all gas refund parameters, so the user knows exactly how much is at risk.

