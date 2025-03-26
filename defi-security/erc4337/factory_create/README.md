# Vulnerability of Using `CREATE` Instead of `CREATE2` in ERC-4337 Factories

In the **ERC-4337** (Account Abstraction) model, new smart contract wallets are typically deployed via a *factory* contract. If that factory relies on `CREATE` (`0xF0`) instead of `CREATE2` (`0xF5`), it introduces non-deterministic wallet addresses and potential vulnerabilities. ERC-4337 explicitly recommends that factories use `CREATE2`, returning **the same wallet address** every time the same parameters are used—even if the wallet is already deployed.

---

## Why `CREATE` Is Problematic

1. **Non-Deterministic Address Generation**  
   - `CREATE` bases the newly created contract’s address on the **factory’s nonce**.  
   - Each transaction that increments the factory’s nonce can change the final address, causing unpredictability and potential confusion.

2. **Front-Running & Replay Attacks**  
   - Attackers can manipulate transaction ordering or intercept a user’s transaction to alter the factory’s nonce.  
   - This could lead to unexpected addresses, or let an attacker deploy a contract at a user’s intended address first.

3. **Funding a Wallet That Doesn’t Exist**  
   - Without a **deterministic** address, users risk sending funds to an address that might never be deployed at all, resulting in lost or irretrievable tokens.

4. **Lack of Reusable Addresses**  
   - If the wallet was already deployed at a given nonce, you can’t reliably re-derive that address to confirm if it’s the “same” wallet.  
   - Bundlers and other off-chain services can’t pre-compute addresses or check if an address is already deployed without complicated state checks on the factory’s nonce.

---

## The `CREATE2` Solution

1. **Deterministic Addressing**  
   - `CREATE2` calculates an address from:
     - The **deployer** (factory) address  
     - A **salt** (user-specific data)  
     - The **creation code**  
     - The **bytecode** of the wallet  
   - Because of this, the wallet address is **independent** of the factory’s nonce or transaction ordering.

2. **Counterfactual Deployment**  
   - Users can generate and share their wallet address **before** it’s actually deployed.  
   - Funds can be sent there immediately, and the wallet contract is deployed only when the user needs to interact.  

3. **Reproducible Address**  
   - If the same salt and code are provided again, `CREATE2` yields **the same** address.  
   - This means the factory can **return that address** even if it’s already been deployed, or if someone tries to deploy it again.  
   - It also allows bundlers to easily query the future address by simulating a call to `getSenderAddress()` without worrying if the contract is currently deployed.

4. **ERC-4337 Compatibility**  
   - The EntryPoint contract expects wallet creation to be repeatable.  
   - If the wallet address is **already deployed**, the factory method should still return **that same** address. This enables services like bundlers to handle user operations seamlessly.

---

## Returning the Same Address Even if Deployed

One core ERC-4337 requirement is that the factory must **return the wallet address** even if the wallet has already been created. This is essential because:

- **Bundlers** can safely simulate the wallet creation (via `initCode`) and get the address without knowing in advance whether the wallet is already deployed.  
- **Idempotent Creation** ensures that repeated calls with the same parameters do not spawn multiple wallets but confirm or reveal the same address.

### Example Scenario

1. **User Operation**  
   - A user sends a `UserOperation` with `initCode` that points to the factory + constructor arguments.  
   - The EntryPoint calls the factory to deploy or confirm the wallet address.

2. **Factory Using `CREATE2`**  
   - If the wallet for those parameters is **not** deployed yet, the factory calls `CREATE2` to deploy it and returns the new address.  
   - If it **is** already deployed, `CREATE2` with the same salt + code results in the **same** address. The factory returns that address again.  

3. **No Address Conflicts**  
   - The user or bundler can rely on the returned address being correct, regardless of nonce ordering or prior attempts.

---

## Takeaways

- **Using `CREATE`** can break the deterministic address property, which is integral to ERC-4337’s goal of “counterfactual” wallet creation.  
- **`CREATE2`** offers **predictable**, **repeatable** deployments, letting the factory return the **same** address if it’s already been created with the same parameters.  
- By adhering to these patterns, ERC-4337 wallets can seamlessly accept funds before actual deployment, minimize front-running risks, and simplify user onboarding.  

Ultimately, **CREATE2** is **not optional**—it’s essential for safe, deterministic account abstraction in an ERC-4337 world, ensuring that the factory can confirm or create a wallet at a stable address each time.
