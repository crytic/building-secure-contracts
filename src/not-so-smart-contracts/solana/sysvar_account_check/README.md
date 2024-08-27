# Missing Sysvar Account Check

The sysvar (system account) account is often used while validating access control for restricted functions by confirming that the inputted sysvar account by the user matches up with the expected sysvar account. Without this check in place, any user is capable of passing in their own spoofed sysvar account and in turn bypassing any further authentication associated with it, causing potentially disastrous effects.

## Exploit Scenario

secp256k1 is an elliptic curve used by a number of blockchains for signatures. Validating signatures is crucial as by bypassing signature checks, an attacker can gain access to restricted functions that could lead to drainage of funds.

Here, `load_current_index` and `load_instruction_at` are functions that don't verify that the inputted sysvar account is authorized, therefore allowing serialized maliciously fabricated data to sucessfully spoof as an authorized secp256k1 signature.

### Example Contract

```rust
pub fn verify_signatures(account_info: &AccountInfo) -> ProgramResult {
    let index = solana_program::sysvar::instructions::load_current_index(
        &account_info.try_borrow_mut_data()?,
    );

    let secp_instruction = sysvar::instructions::load_instruction_at(
        (index - 1) as usize,
        &account_info.try_borrow_mut_data()?,
    );
    if secp_instruction.program_id != secp256k1_program::id() {
        return Err(InvalidSecpInstruction.into());
    }
    ...
}
```

Refer to [Mitigation](https://github.com/crytic/building-secure-contracts/tree/master/not-so-smart-contracts/solana/sysvar_account_check#Mitigation) to understand what's wrong with these functions and how sysvar account checks were added.

## Mitigation

- Solana libraries should be running on version 1.8.1 and up
- Use `load_instruction_at_checked` and `load_current_index_checked`

Utilizing the latest Solana version and referencing checked functions, especially on sensitive parts of a contract is crucial even if potential attack vectors have been fixed post-audit.
Leaving the system exposed to any point of failure compromises the entire system's integrity, especially while the contracts are being constantly updated.

Here is the code showing the sysvar account checks added between unchecked and checked functions:

- [load_instruction_at](https://docs.rs/solana-program/1.13.5/src/solana_program/sysvar/instructions.rs.html#186-188) vs [load_instruction_at_checked](https://docs.rs/solana-program/1.13.5/src/solana_program/sysvar/instructions.rs.html#192-205)
- [load_current_index](https://docs.rs/solana-program/1.13.5/src/solana_program/sysvar/instructions.rs.html#107-112) vs [load_current_index_checked](https://docs.rs/solana-program/1.13.5/src/solana_program/sysvar/instructions.rs.html#116-128)

---

## Example: Wormhole Exploit (February 2022)

### Funds lost: ~326,000,000 USD

**Note: The following analysis is condensed down to be present this attack vector as clearly as possible, and certain details might’ve been left out for the sake of simplification**

The Wormhole hack serves to be one of the most memorable exploits in terms of impact DeFi has ever seen.

This exploit also happens to incorporate a missing sysvar account check that allowed the attacker to:

1. Spoof Guardian signatures as valid
2. Use them to create a Validator Action Approval (VAA)
3. Mint 120,000 ETH via calling complete_wrapped function

(These actions are all chronologically dependent on one another based on permissions and conditions - this analysis will only dive into “Step 1”)

The SignatureSet was able to be faked because the `verify_signatures` function failed to appropriately [verify](https://github.com/wormhole-foundation/wormhole/blob/ca509f2d73c0780e8516ffdfcaf90b38ab6db203/solana/bridge/program/src/api/verify_signature.rs#L101) the sysvar account passed in:

```rust
let secp_ix = solana_program::sysvar::instructions::load_instruction_at(
    secp_ix_index as usize,
    &accs.instruction_acc.try_borrow_mut_data()?,
)
```

`load_instruction_at` doesn't verify that the inputted data came from the authorized sysvar account.

The fix for this was to upgrade the Solana version and get rid of these unsafe deprecated functions (see [Mitigation](https://github.com/crytic/building-secure-contracts/tree/master/not-so-smart-contracts/solana/sysvar_account_check#Mitigation)). Wormhole had [caught](https://github.com/wormhole-foundation/wormhole/commit/7edbbd3677ee6ca681be8722a607bc576a3912c8#diff-0d27d8889edd071b86d3f3299276882d97613ad6ab3b0b6412ae4ebf3ccd6370R92-R103) this issue but didn't update their deployed contracts in time before the exploiter had already managed to drain funds.

## Resources:

[samczsun's Wormhole exploit breakdown thread](https://twitter.com/samczsun/status/1489044939732406275)
