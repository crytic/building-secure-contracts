# Improper Instruction Introspection

Solana allows programs to inspect other instructions in the transaction using the [Instructions sysvar](https://docs.solanalabs.com/implemented-proposals/instruction_introspection). The programs requiring instruction introspection divide an operation into two or more instructions. The program have to ensure that all the instructions related to an operation are correlated. The program could access the instructions using absolute indexes or relative indexes. Using relative indexes ensures that the instructions are implicitly correlated. The programs using absolute indexes might become vulnerable to exploits if additional validations to ensure the correlation between instructions are not performed.

## Exploit Scenario

A program mints tokens based on the amount of tokens transferred to it. A program checks that `Token::transfer` instruction is called in the first instruction of the transaction. The program uses absolute index `0` to access the instruction data, program id and validates them. If the first instruction is a `Token::transfer` then program mints some tokens.

```rust
pub fn mint(
    ctx: Context<Mint>,
    // ...
) -> Result<(), ProgramError> {
    // [...]
    let transfer_ix = solana_program::sysvar::instructions::load_instruction_at_checked(
        0usize,
        ctx.instructions_account.to_account_info(),
    )?;

    if transfer_ix.program_id != spl_token::id() {
        return Err(ProgramError::InvalidInstructionData);
    }
    // check transfer_ix transfers
    // mint to the user account
    // [...]
    Ok(())
}
```

The program uses absolute index to access the transfer instruction. An attacker can create transaction containing multiple calls to `mint` and single transfer instruction.

0. `transfer()`
1. `mint(, ...)`
2. `mint(, ...)`
3. `mint(, ...)`
4. `mint(, ...)`
5. `mint(, ...)`

All the `mint` instructions verify the same transfer instruction. The attacker gets 4 times more than the intended tokens.

## Mitigation

Use a relative index, for example `-1`, and ensure the instruction at that offset is the `transfer` instruction.

```rust
pub fn mint(
    ctx: Context<Mint>,
    // ...
) -> Result<(), ProgramError> {
    // [...]
    let transfer_ix = solana_program::sysvar::instructions::get_instruction_relative(
        -1i64,
        ctx.instructions_account.to_account_info(),
    )?;
    // [...]
}
```
