# Missing Signer Check

In Solana, each public key has a corresponding private key used to generate signatures. A [transaction](https://docs.solana.com/developing/programming-model/transactions) includes a list of the public keys for each account, which were used to generate signatures for the transaction. These signatures are verified using the provided public keys before executing the transaction.

If certain permissions are required to perform a sensitive function in a contract, a missing signer check becomes problematic. Without this check, an attacker could call the respective access-controlled functions without permission.

## Exploit Scenario

In the following example, a contract is designed to change an escrow account's state to `Complete`. However, it does not verify if the `State` account's `authority` has signed the transaction. As a result, a malicious actor can set the state to `Complete` without needing access to the `authority`'s private key.

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

For additional information on various forms of account verification in Solana and their implementation, please refer to the [Solana Cookbook](https://solanacookbook.com/references/programs.html#how-to-verify-accounts).
