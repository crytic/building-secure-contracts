# Missing Signer Check
In Solana, a [transaction](https://docs.solana.com/developing/programming-model/transactions)  lists all account public keys used by the instructions of the transaction. These public keys come with a signature, ensuring that the account holder has authorized the transaction.

Specifically, these signatures used to validate transactions are generated by the account’s private key and are verified by being matched against an inputted public key prior to successful transaction execution.
In case certain permissions are required to perform a sensitive function of the contract, a missing signer check becomes an issue. Any user’s account with the authorized account’s public key will be able to call the respective access controlled functions permissionlessly without ever having to validate their private key.

## Exploit Scenario
The following contract updates the current market owner with a new one. Unfortunately, the only check being done here is against the current owner’s public key prior to setting a new owner. 
Therefore, a malicious actor can set themselves as the new owner without being the actual market owner. This is because the current owner’s private key isn’t being verified considering the contract doesn’t check that the attacker has signed or not.

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
  	if !EXPECTED_ACCOUNT.is_signer {
    	return Err(ProgramError::MissingRequiredSignature);
	}
```
For further reading on different forms of account verification in Solana and implementation refer to the [Solana Cookbook](https://solanacookbook.com/references/programs.html#how-to-verify-accounts)