# Correcting Improper PDA Bump Seed Validation

PDAs (Program Derived Addresses) are, by definition, [program-controlled](https://docs.solana.com/terminology#program-derived-account-pda) accounts that can sign without the need for a private key. PDAs are generated through a set of seeds and a program id, which are together hashed to verify that the point doesn't lie on the ed25519 curve (the curve used by Solana to sign transactions).

Values on this elliptic curve have a corresponding private key, which would disqualify them from being a PDA. If a point lying on the elliptic curve is found, our 32-byte address is modified through the addition of a bump to remove it from the curve. A bump, represented by a single byte iterating from 255 to 0, is added onto our input until a point that doesn’t lie on the elliptic curve is generated. This means we've found an address without an associated private key.

The issue arises when seeds have multiple bumps, allowing for various valid PDAs to be generated from the same seeds. An attacker can create a PDA with the correct program ID but using a different bump. Without any explicit check against the bump seed itself, the program becomes vulnerable to the attacker tricking the program into thinking they're using the expected PDA when they're actually interacting with an illegitimate account.

You can view ToB's lint implementation for the bump seed canonicalization issue [here](https://github.com/crytic/solana-lints/tree/master/lints/bump_seed_canonicalization).

## Exploit Scenario

In Solana, the `create_program_address` function generates a 32-byte address based on a set of seeds and a program address. On its own, the point may lie on the ed25519 curve. Consider the following example without any other validation being referenced within a sensitive function, such as one that manages transfers. In this case, a spoofed PDA could be created by a user-controlled PDA that was passed in.

### Example Contract

```rust
let program_address = Pubkey::create_program_address(&[key.to_le_bytes().as_ref(), &[reserve_bump]], program_id)?;

...
```

## Mitigation

The `find_program_address` function finds the largest bump seeds for which a corresponding PDA exists (i.e., a point not on the ed25519 curve) and returns both the address and the bump seed. The function panics if no PDA address can be found.

```rust
        let (address, _system_bump) = Pubkey::find_program_address(&[key.to_le_bytes().as_ref()], program_id);

        if program_address != &account_data.key() {
            return Err(ProgramError::InvalidAddress);
        }
```
