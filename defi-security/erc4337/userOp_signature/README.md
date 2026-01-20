# Signature Validation and Return Codes in ERC-4337

To be compliant with EIP-4337 standards, under **ERC-4337**, user operations (UserOps) are validated by the account contract itself rather than relying on the built-in EOA signature mechanism. When an account does **not** implement signature aggregation, it must directly validate the UserOp’s signature. Specifically:

1. **Hashing the UserOp**  
   - The account receives a `userOpHash`, which is a hash of:
     - The user operation fields (excluding the signature).  
     - The `entryPoint` address.  
     - The `chainId`.  
   - This unique hash ensures that each UserOp is tied to a specific chain and entry point, preventing replay on different networks or entry points.

2. **Signature Check**  
   - The account **must** confirm that the provided signature is valid **for** the `userOpHash`.  
   - If the signature is **invalid**, the contract should return a **special code** (`SIG_VALIDATION_FAILED`) rather than reverting the transaction.

3. **Non-Revert on Signature Mismatch**  
   - **Why not revert?**  
     - Reverting prevents the bundler from distinguishing a genuine signature failure from a broader contract error.  
     - By returning `SIG_VALIDATION_FAILED`, the account signals to the bundler that the user’s signature is incorrect—so the operation can be rejected without incurring wasted gas or ambiguous error handling.

4. **Other Errors Must Revert**  
   - If any error besides an invalid signature occurs (e.g., malformed UserOp data, out-of-gas conditions, unauthorized function calls), the contract **must** revert.  
   - This clear distinction between a “bad signature” (non-revert) and a “contract error” (revert) helps the bundler handle user operations more reliably.

---

## Example Flow

1. **Bundler**  
   - Gathers multiple UserOps into a batch.  
   - Calls `validateUserOp` on each user’s account.

2. **Account Contract**  
   - Computes or receives the `userOpHash`.  
   - Validates the user’s signature:
     ```solidity
     if (!isValidSignature(userOpHash, signature)) {
         return SIG_VALIDATION_FAILED;
     }
     ```
   - If the signature is valid, the function returns `0` (or another success indicator). If any other error arises (e.g., the contract can’t parse input), it reverts.

3. **Bundler’s Response**  
   - If the account returns `SIG_VALIDATION_FAILED`, the bundler knows to drop this operation from the batch.  
   - If the account reverts, it indicates an internal error with the operation or the contract logic.

---

## Key Takeaways

- **No Signature Aggregation**: The account is responsible for direct signature verification.  
- **Return Codes**: An **invalid signature** yields `SIG_VALIDATION_FAILED`, while **all other errors** must revert.  
