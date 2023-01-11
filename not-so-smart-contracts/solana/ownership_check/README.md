# Missing Ownership Check
Accounts in Solana include metadata of an owner. These owners are identified by their own program ID. Without sufficient checks that the expected program ID matches that of the passed in account, an attacker can fabricate account data to pass any other preconditions and bypass the ownership check. 

This malicious account will inherently have a different program ID, but considering there’s no check that the program ID is the same, as long as the other preconditions are passed the attacker can trick the program into thinking their malicious account is the expected authorized account.

## Exploit Scenario
The following contract updates the current market owner with a new one. Unfortunately, the only check being done here is against the current owner’s public key prior to setting a new owner. 
Therefore, a malicious actor can set themselves as the new owner without being the actual market owner. This is because the ownership of the market owner account isn’t being fully verified against itself by program ID. Since there’s no check that the market is the one owned by the program itself, an attacker can pass in their own fabricated account data which is then verified against a public key of the current owner’s account, making it easy to set themselves as the new owner. 

### Example Contract 
```rust
fn set_owner(program_id: &Pubkey, new_owner: Pubkey, accounts: &[AccountInfo]) -> ProgramResult {
	let account_info_iter = &mut accounts.iter();
	let market_info = next_account_info(account_info_iter)?;
	let current_owner = next_account_info(account_info_iter)?;

	let mut market = Market::unpack(&market_info.data.borrow())?;
 
	if &market.owner != current_owner.pubkey {
    	    return Err(InvalidMarketOwner.into());
	}
	market.owner = new_owner;

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
