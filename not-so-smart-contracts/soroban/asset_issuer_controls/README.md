# Stellar Asset Issuer Controls

Stellar assets can be clawed back or frozen by their issuer, which breaks contracts that assume the tokens they hold are always available.

## Description

Classic Stellar assets are exposed to Soroban through the Stellar Asset Contract (SAC). Unlike most token standards, the SAC gives the asset's admin (initially the issuer) powers over other holders' balances, including balances held by contracts:

- `clawback(from, amount)` burns tokens from a holder, if clawback was enabled on the issuer when the balance was created.
- `set_authorized(id, false)` deauthorizes a holder, if the issuer has the revocable flag. A deauthorized holder can no longer send or receive the asset.

Many regulated assets, such as stablecoins and tokenized securities, enable these flags. A contract that pools user funds and keeps its own record of each user's balance can end up with fewer tokens than it owes:

- After a clawback, the contract's internal balances exceed its real balance. Early withdrawers are paid in full, and the last users cannot withdraw.
- After deauthorization, every transfer out of the contract fails, locking all users' funds.

In addition, classic Stellar accounts (`G...` addresses) need a trustline before they can hold a classic asset. Transfers to an account without a trustline fail, which can block a function that pays several recipients in one transaction.

## Exploit Scenario

Alice deploys a vault that accepts a regulated stablecoin and records each deposit. Bob and Carol each deposit 500. The issuer claws back 400 from the vault because of a dispute related to another user. Bob withdraws his 500, and Carol's withdrawal of 500 fails because the vault holds only 100. Later, the issuer deauthorizes the vault, and every withdrawal fails.

## Example

```rust
#[contractimpl]
impl Vault {
    pub fn withdraw(env: Env, to: Address, amount: i128) {
        to.require_auth();
        if amount <= 0 {
            panic!("invalid amount");
        }
        let key = DataKey::Balance(to.clone());
        let balance: i128 = env.storage().persistent().get(&key).unwrap_or(0);
        if balance < amount {
            panic!("insufficient balance");
        }
        env.storage().persistent().set(&key, &(balance - amount));
        let token: Address = env.storage().instance().get(&DataKey::Token).unwrap();
        // Fails if the issuer clawed back the vault's tokens or deauthorized the vault
        token::Client::new(&env, &token).transfer(&env.current_contract_address(), &to, &amount);
    }
}
```

## Mitigations

- Before supporting a Stellar asset, check whether its issuer has the clawback or revocable flags, and document what happens to users' funds if those powers are used.
- Track user positions as shares of the contract's actual token balance, so that a clawback is shared between all users instead of falling on the last ones to withdraw.
- Let each user withdraw independently, and avoid functions that must transfer to many recipients in a single transaction.
- Make sure the protocol can be paused and keeps working for unaffected assets if one asset is frozen.

## References

- [Stellar docs: Stellar Asset Contract](https://developers.stellar.org/docs/tokens/stellar-asset-contract)
