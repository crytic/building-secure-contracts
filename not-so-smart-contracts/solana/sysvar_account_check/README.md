# Missing Sysvar Account Check
The sysvar (system account) account is often used while validating access control for restricted functions by confirming that the inputted sysvar account by the user matches up with the expected sysvar account. Without this check in place, any user is capable of passing in their own spoofed sysvar account and in turn bypassing any further authentication associated with it, causing potentially disastrous effects.

## Exploit Scenario

Consider the following:

During signature verification, one of the only points of authentication is the signer being checked against the actual expected address. 

One of the only points of validation of the passed in sysvar account is deserializing the instruction and verifying the data length.

Consider the function load_instruction_at. This takes in the inputted sysvar account data, but on its own, fails to check if the inputted sysvar account is the actual one, making the function vulnerable to spoofing.
In this scenario, spoofing instruction data to match a valid and authorized address would make an easy attack vector to bypass signature checks.


## Example: Wormhole Exploit (February 2022)
### Funds lost: ~326,000,000 USD

**Note: The following analysis is condensed down to be present this attack vector as clearly as possible, and certain details might’ve been left out for the sake of simplification**

The Wormhole hack serves to be one of the most memorable exploits in terms of impact DeFi has ever seen. 

This exploit also happens to incorporate a missing sysvar account check that allowed the attacker to:
1. Spoof Guardian signatures as valid
2. Use them to create a Validator Action Approval (VAA)
3. Mint 120,000 ETH via calling complete_wrapped function

(These actions are all chronologically dependent on one another based on permissions and conditions - this analysis will only dive into “Step 1”)

The SignatureSet was able to be faked because the verify_signatures function failed to appropriately [verify](https://github.com/wormhole-foundation/wormhole/blob/ca509f2d73c0780e8516ffdfcaf90b38ab6db203/solana/bridge/program/src/api/verify_signature.rs#L101
) the sysvar account passed in:

```rust
let secp_ix = solana_program::sysvar::instructions::load_instruction_at(
    secp_ix_index as usize,
    &accs.instruction_acc.try_borrow_mut_data()?,
)
```
load_instruction_at doesn't verify that the inputted data came from the authorized sysvar account. This function was later deprecated after Solana version 1.8.0 and replaced by load_instruction_at_checked which conducts the proper checks as shown here:

**load_instruction_at**

```rust
pub fn load_instruction_at(index: usize, data: &[u8]) -> Result<Instruction, SanitizeError> {
    crate::message::Message::deserialize_instruction(index, data)
}
```
**load_instruction_at_checked**

```rust
pub fn load_instruction_at_checked(
    index: usize,
    instruction_sysvar_account_info: &AccountInfo,
) -> Result<Instruction, ProgramError> {
    if !check_id(instruction_sysvar_account_info.key) {
        return Err(ProgramError::UnsupportedSysvar);
    }

    let instruction_sysvar = instruction_sysvar_account_info.try_borrow_data()?;
    crate::message::Message::deserialize_instruction(index, &instruction_sysvar).map_err(|err| {
        match err {
            SanitizeError::IndexOutOfBounds => ProgramError::InvalidArgument,
            _ => ProgramError::InvalidInstructionData,
        }
    })
}
```

The fix for this was to upgrade the Solana version and get rid of these unsafe deprecated functions (see [Mitigation](https://github.com/crytic/building-secure-contracts/new/nssc-solana-sysvar/not-so-smart-contracts#mitigation)). Wormhole had [caught](https://github.com/wormhole-foundation/wormhole/commit/7edbbd3677ee6ca681be8722a607bc576a3912c8#diff-0d27d8889edd071b86d3f3299276882d97613ad6ab3b0b6412ae4ebf3ccd6370R92-R103)  this issue but didn't update their deployed contracts in time before the exploiter had already managed to drain funds.


## Mitigation
Solana libraries should be running on version 1.8.1 and up.
Since version 1.8.0, the load_instruction_at function has been [deprecated](https://docs.rs/solana-program/1.8.1/solana_program/sysvar/instructions/fn.load_instruction_at.html) and replaced with load_instruction_at_checked

Utilizing the latest Solana version and referencing checked functions, especially on sensitive parts of a contract is crucial even if potential attack vectors have been fixed post-audit. 
Leaving the system exposed to any point of failure compromises the entire system's integrity, especially while the contracts are being constantly updated.


