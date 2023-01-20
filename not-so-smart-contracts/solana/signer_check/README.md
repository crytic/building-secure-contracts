# Missing Signer Check
In Solana, each public key has an associated private key that can be used to generate signatures. A [transaction](https://docs.solana.com/developing/programming-model/transactions) lists each account public key whose private key was used to generate a signature for the transaction. These signatures are verified using the inputted public keys prior to transaction execution.

In case certain permissions are required to perform a sensitive function of the contract, a missing signer check becomes an issue. Without this check, an attacker would be able to call the respective access controlled functions permissionlessly.

## Exploit Scenario
The following contract updates the current market authority with a new one. Unfortunately, the only check being done here is against the current authority’s public key prior to setting a new authority.
Therefore, a malicious actor can set themselves as the new authority without being the actual market authority. This is because the current authority’s private key isn’t being verified considering the contract doesn’t check whether the account holder has signed or not.

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
  	if !EXPECTED_ACCOUNT.is_signer {
    	return Err(ProgramError::MissingRequiredSignature);
	}
```
For further reading on different forms of account verification in Solana and implementation refer to the [Solana Cookbook](https://solanacookbook.com/references/programs.html#how-to-verify-accounts).
