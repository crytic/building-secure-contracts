# Custom Account Auth Context

A custom account whose `__check_auth` verifies signatures but ignores the authorization contexts lets every valid key authorize every action.

## Description

Any Soroban contract can act as an account by implementing `CustomAccountInterface`. When another contract calls `require_auth()` on its address, the host calls the account's `__check_auth` with three arguments:

- `signature_payload`: the hash that was signed
- `signatures`: the account's custom signature type
- `auth_contexts`: every contract call (and contract creation) that this authorization covers, with the contract address, the function name, and the arguments

The host verifies nothing about the contexts on behalf of the account. Policies such as "this session key may only call the game contract" or "this key may spend at most 100 USDC per day" exist only if `__check_auth` enforces them by inspecting `auth_contexts`. If it only checks that the signature is valid, any key that the account accepts can authorize any call, including token transfers, changes to the account's signers, and upgrades.

## Exploit Scenario

Alice uses a smart wallet that stores a session key on her gaming device, intended only for calling `play` on a game contract. The wallet's `__check_auth` checks the session key's signature but never looks at `auth_contexts`. Bob steals the device and uses the session key to sign a `transfer` of all of Alice's tokens to himself. The wallet approves it.

## Example

```rust
#[contractimpl]
impl CustomAccountInterface for SessionWallet {
    type Signature = BytesN<64>;
    type Error = Error;

    fn __check_auth(
        env: Env,
        signature_payload: Hash<32>,
        signature: BytesN<64>,
        _auth_contexts: Vec<Context>,
    ) -> Result<(), Error> {
        let session_key: BytesN<32> = env.storage().instance().get(&DataKey::SessionKey).unwrap();
        env.crypto().ed25519_verify(&session_key, &signature_payload.into(), &signature);
        // BUG: `_auth_contexts` is ignored, so the session key can authorize anything
        Ok(())
    }
}
```

## Mitigations

- Check every entry in `auth_contexts` against the key's permissions, and reject anything that is not explicitly allowed, including contract creation contexts:

```rust
let game: Address = env.storage().instance().get(&DataKey::Game).unwrap();
for context in auth_contexts.iter() {
    match context {
        Context::Contract(c) if c.contract == game && c.fn_name == symbol_short!("play") => {}
        _ => return Err(Error::NotAllowed),
    }
}
```

- Do not stop at the first allowed context. A signature can cover several calls, and an attacker can combine an allowed call with a malicious one.
- When enforcing limits (such as spending limits), decode and check the arguments in the context, not only the function name.
- Require stronger authorization (for example, all signers) for calls that modify the account itself.

## References

- [Stellar docs: Complex account example](https://developers.stellar.org/docs/build/smart-contracts/example-contracts/complex-account)
