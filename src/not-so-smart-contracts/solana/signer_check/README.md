# Missing Signer Check

In Solana, each public key has an associated private key that can be used to generate signatures. A [transaction](https://docs.solana.com/developing/programming-model/transactions) lists each account public key whose private key was used to generate a signature for the transaction. These signatures are verified using the inputted public keys prior to transaction execution.

In case certain permissions are required to perform a sensitive function of the contract, a missing signer check becomes an issue. Without this check, an attacker would be able to call the respective access controlled functions permissionlessly.

## Exploit Scenario

The following contract sets an escrow account's state to `Complete`. Unfortunately, the contract does not check whether the `State` account's `authority` has signed the transaction.
Therefore, a malicious actor can set the state to `Complete`, without needing access to the `authority`’s private key.

### Example Contract

```rust
fn complete_escrow(_program_id: &Pubkey, accounts: &[AccountInfo], _instruction_data: &[u8]) -> ProgramResult {
    let account_info_iter = &mut accounts.iter();
    let state_info = next_account_info(account_info_iter)?;
    let authority = next_account_info(account_info_iter)?;

    let mut state = State::deserialize(&mut &**state_info.data.borrow())?;

    if state.authority != *authority.key {
        return Err(ProgramError::IncorrectAuthority);
    }

    state.escrow_state = EscrowState::Complete;
    state.serialize(&mut &mut **state_info.data.borrow_mut())?;

    Ok(())

}
```

_Inspired by [SPL Lending Program](https://github.com/solana-labs/solana-program-library/tree/master/token-lending/program)_

## Mitigation

```rust
  	if !EXPECTED_ACCOUNT.is_signer {
    	return Err(ProgramError::MissingRequiredSignature);
	}
```

For further reading on different forms of account verification in Solana and implementation refer to the [Solana Cookbook](https://solanacookbook.com/references/programs.html#how-to-verify-accounts).
