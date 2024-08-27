# Missing Ownership Check

Accounts in Solana include metadata of an owner. These owners are identified by their own program ID. Without sufficient checks that the expected program ID matches that of the passed in account, an attacker can fabricate an account with spoofed data to pass any other preconditions.

This malicious account will inherently have a different program ID as owner, but considering there’s no check that the program ID is the same, as long as the other preconditions are passed, the attacker can trick the program into thinking their malicious account is the expected account.

## Exploit Scenario

The following contract allows funds to be dispersed from an escrow account vault, provided the escrow account's state is `Complete`. Unfortunately, there is no check that the `State` account is owned by the program.
Therefore, a malicious actor can pass in their own fabricated `State` account with spoofed data, allowing the attacker to send the vault's funds to themselves.

### Example Contract

```rust
fn pay_escrow(_program_id: &Pubkey, accounts: &[AccountInfo], _instruction_data: &[u8]) -> ProgramResult {
    let account_info_iter = &mut accounts.iter();
    let state_info = next_account_info(account_info_iter)?;
    let escrow_vault_info = next_account_info(account_info_iter)?;
    let escrow_receiver_info = next_account_info(account_info_iter)?;

    let state = State::deserialize(&mut &**state_info.data.borrow())?;

    if state.escrow_state == EscrowState::Complete {
        **escrow_vault_info.try_borrow_mut_lamports()? -= state.amount;
        **escrow_receiver_info.try_borrow_mut_lamports()? += state.amount;
    }

    Ok(())
}
```

_Inspired by [SPL Lending Program](https://github.com/solana-labs/solana-program-library/tree/master/token-lending/program)_

## Mitigation

```rust
  	if EXPECTED_ACCOUNT.owner != program_id {
    	    return Err(ProgramError::IncorrectProgramId);
	}
```

For further reading on different forms of account verification in Solana and implementation refer to the [Solana Cookbook](https://solanacookbook.com/references/programs.html#how-to-verify-accounts).
