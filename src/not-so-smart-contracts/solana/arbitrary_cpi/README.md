# Arbitrary CPI

Solana allows programs to call one another through cross-program invocation (CPI). This can be done via `invoke`, which is responsible for routing the passed in instruction to the program. Whenever an external contract is invoked via CPI, the program must check and verify the program ID. If the program ID isn't verified, then the contract can call an attacker-controlled program instead of the intended one.

View ToB's lint implementation for the arbitrary CPI issue [here](https://github.com/crytic/solana-lints/tree/master/lints/arbitrary_cpi).

## Exploit Scenario

Consider the following `withdraw` function. Tokens are able to be withdrawn from the pool to a user account. The program invoked here is user-controlled and there's no check that the program passed in is the intended `token_program`. This allows a malicious user to pass in their own program with functionality to their discretion - such as draining the pool of the inputted `amount` tokens.

### Example Contract

```rust
   pub fn withdraw(accounts: &[AccountInfo], amount: u64) -> ProgramResult {
        let account_info_iter = &mut accounts.iter();
        let token_program = next_account_info(account_info_iter)?;
        let pool = next_account_info(account_info_iter)?;
        let pool_auth = next_account_info(account_info_iter)?;
        let destination = next_account_info(account_info_iter)?;
        invoke(
            &spl_token::instruction::transfer(
                &token_program.key,
                &pool.key,
                &destination.key,
                &pool_auth.key,
                &[],
                amount,
            )?,
            &[
                &pool.clone(),
                &destination.clone(),
                &pool_auth.clone(),
            ],
        )
    }
```

_Inspired by [Sealevel](https://github.com/coral-xyz/sealevel-attacks/)_

## Mitigation

```rust
        if INPUTTED_PROGRAM.key != &INTENDED_PROGRAM::id() {
            return Err(ProgramError::InvalidProgramId);
        }
```
