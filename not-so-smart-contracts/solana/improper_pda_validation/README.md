# Improper PDA bump seed validation

PDAs (Program Derived Addresses) are, by definition, [program-controlled](https://docs.solana.com/terminology#program-derived-account-pda) accounts and therefore can be used to sign without the need to provide a private key. PDAs are generated through a set of seeds and a program id, which are then collectively hashed to verify that the point doesn't lie on the ed25519 curve (the curve used by Solana to sign transactions).

Values on this elliptic curve have a corresponding private key, which wouldn't make it a PDA. In the case a point lying on the elliptic curve is found, our 32-byte address is modified through the addition of a bump to "bump" it off the curve. A bump, represented by a singular byte iterating through 255 to 0, is added onto our input until a point that doesn’t lie on the elliptic curve is generated, meaning that we’ve found an address without an associated private key.

The issue arises with seeds being able to have multiple bumps, thus allowing varying PDAs that are valid from the same seeds. An attacker can create a PDA with the correct program ID but with a different bump. Without any explicit check against the bump seed itself, the program leaves itself vulnerable to the attacker tricking the program into thinking they’re using the expected PDA when in fact they're interacting with an illegitimate account.

View ToB's lint implementation for the bump seed canonicalization issue [here](https://github.com/crytic/solana-lints/tree/master/lints/bump_seed_canonicalization).

## Exploit Scenario

In Solana, the `create_program_address` function creates a 32-byte address based off the set of seeds and program address. On its own, the point may lie on the ed25519 curve. Consider the following without any other validation being referenced within a sensitive function, such as one that handles transfers. That PDA could be spoofed by a passed in user-controlled PDA.

### Example Contract

```rust
let program_address = Pubkey::create_program_address(&[key.to_le_bytes().as_ref(), &[reserve_bump]], program_id)?;

...
```

## Mitigation

The `find_program_address` function finds the largest bump seeds for which there exists a corresponding PDA (i.e., a point not on the ed25519 curve), and returns both the address and the bump seed. The function panics in the case that no PDA address can be found.

```rust
        let (address, _system_bump) = Pubkey::find_program_address(&[key.to_le_bytes().as_ref()], program_id);

        if program_address != &account_data.key() {
            return Err(ProgramError::InvalidAddress);
        }
```
