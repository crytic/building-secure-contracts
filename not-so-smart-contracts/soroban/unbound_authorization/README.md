# Unbound Authorization

Calling `require_auth` on an address supplied by the caller proves only that the caller signed, not that the caller is allowed to act.

## Description

`Address::require_auth()` answers one question: did this address authorize this invocation? It does not check that the address holds any role. A common mistake in admin functions is to accept the admin as a parameter and call `require_auth()` on it, without comparing it to the admin stored in the contract. The authorization check passes for any address, as long as that address signs, so the attacker can pass their own address.

## Exploit Scenario

Alice deploys a pool whose `set_fee_rate(admin, fee_rate)` function calls `admin.require_auth()`. Bob calls `set_fee_rate(bob, 10_000)` and signs with his own key. The authorization check succeeds because Bob authorized the call, and Bob sets the pool's fee to 100%.

## Example

```rust
#[contractimpl]
impl Pool {
    pub fn __constructor(env: Env, admin: Address) {
        env.storage().instance().set(&DataKey::Admin, &admin);
    }

    pub fn set_fee_rate(env: Env, admin: Address, fee_rate: u32) {
        // BUG: `admin` is never compared with the stored admin
        admin.require_auth();
        env.storage().instance().set(&DataKey::FeeRate, &fee_rate);
    }
}
```

## Mitigations

- Load the privileged address from storage and call `require_auth()` on that stored value, instead of accepting it as an argument:

```rust
pub fn set_fee_rate(env: Env, fee_rate: u32) {
    let admin: Address = env.storage().instance().get(&DataKey::Admin).unwrap();
    admin.require_auth();
    env.storage().instance().set(&DataKey::FeeRate, &fee_rate);
}
```

- If the role holder must be passed as an argument (for example, one of several operators), check it against the stored role before calling `require_auth()`.
