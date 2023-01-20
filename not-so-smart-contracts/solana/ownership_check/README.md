# Missing Ownership Check
Accounts in Solana include metadata of an owner. These owners are identified by their own program ID. Without sufficient checks that the expected program ID matches that of the passed in account, an attacker can fabricate an account with spoofed data to pass any other preconditions.

This malicious account will inherently have a different program ID as owner, but considering there’s no check that the program ID is the same, as long as the other preconditions are passed, the attacker can trick the program into thinking their malicious account is the expected account.

## Exploit Scenario
The following contract updates the current market authority with a new one. Unfortunately, the only check being done here is against the current authority’s public key prior to setting a new authority.
Therefore, a malicious actor can set themselves as the new authority without being the actual market authority. This is because the ownership of the market authority account isn’t being fully verified against itself by program ID. Since there’s no check that the market is owned by the program itself, an attacker can pass in their own fabricated account with spoofed data which is then verified against the public key of the current authority’s account, making it easy for the attacker to set themselves as the new authority.

### Example Contract
```rust
fn set_authority(program_id: &Pubkey, new_authority: Pubkey, accounts: &[AccountInfo]) -> ProgramResult {
	let account_info_iter = &mut accounts.iter();
	let market_info = next_account_info(account_info_iter)?;
	let current_authority = next_account_info(account_info_iter)?;

	let mut market = Market::unpack(&market_info.data.borrow())?;

	if &market.authority != current_authority.pubkey {
    	    return Err(InvalidMarketAuthority.into());
	}
	market.authority = new_authority;

  ...

	Ok(())
}
```
*Inspired by [SPL Lending Program](https://github.com/solana-labs/solana-program-library/tree/master/token-lending/program)*

## Mitigation

```rust
  	if EXPECTED_ACCOUNT.owner != program_id {
    	    return Err(ProgramError::IncorrectProgramId);
	}
```
For further reading on different forms of account verification in Solana and implementation refer to the [Solana Cookbook](https://solanacookbook.com/references/programs.html#how-to-verify-accounts).
