# Unprotected Upgrade

An upgrade function without authorization lets anyone replace the contract's code while keeping its address, storage, and balances.

## Description

A Soroban contract can replace its own executable with `env.deployer().update_current_contract()` (named `update_current_contract_wasm()` before soroban-sdk 28). The contract keeps its address, its storage, and every token balance it holds; only the code changes. The new code takes effect once the current invocation completes successfully.

If the upgrade entry point does not require the admin's authorization, an attacker can upload any Wasm and point the contract at it. The attacker's code then runs with full access to the contract's storage and can transfer every asset the contract holds.

## Exploit Scenario

Alice deploys a vault with an `upgrade(new_wasm_hash)` function so that she can ship fixes. Bob uploads a contract whose code lets anyone become admin and withdraw everything, then calls `upgrade` with its hash. From the next transaction onwards, the vault runs Bob's code with the vault's address and funds.

## Example

```rust
#[contractimpl]
impl Vault {
    pub fn upgrade(env: Env, new_wasm_hash: BytesN<32>) {
        // BUG: no authorization
        env.deployer().update_current_contract(ContractExecutable::Wasm(new_wasm_hash));
    }
}
```

## Mitigations

- Require the stored admin's authorization before upgrading:

```rust
pub fn upgrade(env: Env, new_wasm_hash: BytesN<32>) {
    let admin: Address = env.storage().instance().get(&DataKey::Admin).unwrap();
    admin.require_auth();
    env.deployer().update_current_contract(ContractExecutable::Wasm(new_wasm_hash));
}
```

- Make the admin a multisig or a timelock contract so that users can review an upgrade before it executes.
- Be aware that `ContractExecutable::ExternalRef` gives the referenced owner control over the contract's code. Only use it with an owner you trust as much as the admin.
- If the contract does not need to be upgradeable, do not expose an upgrade function.
- Consider using [Scout](https://github.com/CoinFabrik/scout-soroban), which detects unprotected calls that update the contract's Wasm.

## References

- [Stellar docs: Upgrading Wasm bytecode for a deployed contract](https://developers.stellar.org/docs/build/guides/conventions/upgrading-contracts)
