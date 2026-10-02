# Unvalidated Contract Address

Contracts that call a caller-supplied contract address can be fed a malicious contract that implements the expected interface but behaves differently.

## Description

In Soroban, tokens, oracles, pools, and other dependencies are contracts identified by an `Address`. Any account can deploy a contract with the same function names and signatures as a legitimate one. When a function accepts a contract address as an argument and calls it without checking it against a stored, trusted address, the attacker chooses the code that runs.

A common case is a vault that takes the token address as an argument to `deposit`. A fake token whose `transfer` does nothing lets the attacker be credited for a deposit that never happened.

## Exploit Scenario

Alice deploys a vault for USDC. Its `deposit(token, from, amount)` function calls `transfer` on the `token` argument and then credits `from` with `amount`, while `withdraw` always pays out in the real USDC. Bob deploys a contract with an empty `transfer` function, calls `deposit(fake_token, bob, 1000)`, and is credited 1000 without sending anything. He then withdraws 1000 USDC deposited by other users.

## Example

```rust
#[contractimpl]
impl Vault {
    pub fn deposit(env: Env, token: Address, from: Address, amount: i128) {
        from.require_auth();
        if amount <= 0 {
            panic!("invalid amount");
        }
        // BUG: `token` is chosen by the caller
        token::Client::new(&env, &token).transfer(&from, &env.current_contract_address(), &amount);

        let key = DataKey::Balance(from);
        let balance: i128 = env.storage().persistent().get(&key).unwrap_or(0);
        env.storage().persistent().set(&key, &(balance + amount));
    }
}
```

## Mitigations

- Store trusted contract addresses at deployment (for example, in the constructor) and read them from storage instead of accepting them as arguments:

```rust
pub fn deposit(env: Env, from: Address, amount: i128) {
    from.require_auth();
    // ...
    let token: Address = env.storage().instance().get(&DataKey::Token).unwrap();
    token::Client::new(&env, &token).transfer(&from, &env.current_contract_address(), &amount);
    // ...
}
```

- If a contract must support many tokens or pools, keep an allowlist managed by the admin and check every address against it.
- Where possible, credit users based on the change in the contract's own balance of the trusted token rather than on the requested amount.
