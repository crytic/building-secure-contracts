# Preventing Signature Replay Attacks in Multi-Chain Ecosystems

When bridging assets between different blockchains, users typically sign messages or transactions that authorize their tokens to be transferred across networks. While this provides seamless interoperability, it also introduces a **signature replay** risk: a valid signature on one chain might be **reused** on another chain if no measures are taken to differentiate where the signature is supposed to be applied.

---

## What Is a Signature Replay Attack?

A signature replay attack occurs when:
1. **A user signs** a transaction or message on one blockchain (e.g., Ethereum Mainnet).
2. **The signature is still valid** on another chain (e.g., BNB Smart Chain or Polygon) because the system does not bind the signature to a specific network or context.
3. An attacker **reuses** this signature on the secondary chain, effectively duplicating the original transaction, which can lead to unauthorized asset movement or repeated token mints.

---

## Example: Vulnerable Cross-Chain Bridge

Let’s say Alice wants to move tokens from **Chain A**  to **Chain B** . She creates a signature that authorizes the transfer of 100 tokens to a bridge contract. Once those tokens have been locked or burned on Chain A, an equivalent amount is minted for her on Chain B. However, if the bridge contract on **Chain C** (Polygon) also accepts the exact same signature without verifying that it is specific to Chain A, an attacker could take Alice’s signature and replay it on Polygon, minting another 100 tokens for free.

### Attack Steps
1. **Alice Authorizes Transfer**  
   - Alice signs data indicating she is moving 100 tokens from Chain A to Chain B.
2. **Chain B Bridge Validates**  
   - The bridge on Chain B sees Alice’s valid signature and releases 100 tokens to her address.
3. **Signature Replay on Chain C**  
   - A malicious actor sends the same signature to the bridge on Chain C, which incorrectly treats it as a new request.
   - Since the signature is accepted again, another 100 tokens are minted on Chain C—effectively duplicating the transaction.

---

### Mitigation

Incorporate the chain ID or a domain separator (e.g., using EIP-712) into the signed data. This way, a signature for chain ID 1 (Ethereum Mainnet) cannot be accepted on chain ID 56 (BNB Smart Chain).
