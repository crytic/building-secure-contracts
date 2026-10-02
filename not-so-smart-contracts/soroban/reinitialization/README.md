# Re-initialization

An `initialize` function that can be called more than once lets an attacker overwrite the admin or configuration after deployment.

## Description

Before Protocol 22, Soroban contracts could not run code at deployment, so they exposed a public `initialize` function to store the admin, the token addresses, and other configuration. Such a function is an ordinary entry point: unless it checks whether the contract is already initialized, anyone can call it again and replace the stored values. Even with that check, a contract that is deployed and initialized in two separate transactions can be front-run, and the attacker initializes it first.

Since Protocol 22 (soroban-sdk 22), a contract can define a `__constructor` function. The host runs it atomically as part of contract creation, and it cannot be invoked afterwards (the host rejects direct calls to functions whose names start with `__`).

## Exploit Scenario

Alice deploys a vault and calls `initialize(alice)`. Bob calls `initialize(bob)`. The vault now stores Bob as admin, and Bob can use every admin-only function, including withdrawals and upgrades.

## Example

```rust
#[contractimpl]
impl Vault {
    pub fn initialize(env: Env, admin: Address) {
        // BUG: no check that the contract is already initialized
        env.storage().instance().set(&DataKey::Admin, &admin);
    }
}
```

## Mitigations

- Use a constructor, which runs exactly once when the contract is created:

```rust
#[contractimpl]
impl Vault {
    pub fn __constructor(env: Env, admin: Address) {
        env.storage().instance().set(&DataKey::Admin, &admin);
    }
}
```

- If an `initialize` function is unavoidable, make it fail when the contract is already initialized, and deploy and initialize the contract in the same transaction (for example, from a factory contract):

```rust
pub fn initialize(env: Env, admin: Address) {
    if env.storage().instance().has(&DataKey::Admin) {
        panic_with_error!(&env, Error::AlreadyInitialized);
    }
    env.storage().instance().set(&DataKey::Admin, &admin);
}
```

## References

- [CAP-0058: Constructors for Soroban contracts](https://github.com/stellar/stellar-protocol/blob/master/core/cap-0058.md)
