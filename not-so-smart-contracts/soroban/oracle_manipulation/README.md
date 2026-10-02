# Thin Market Oracle Manipulation

Lending protocols that value collateral with a price derived from an illiquid market can be drained by an attacker who trades that price up.

## Description

Soroban protocols commonly read prices from oracles that implement [SEP-40](https://github.com/stellar/stellar-protocol/blob/master/ecosystem/sep-0040.md), such as Reflector. These oracles derive prices from trading activity, for example on the Stellar DEX. If an asset trades very little, a single trade between two accounts controlled by the attacker can set the reported price. The attacker then deposits the overvalued asset as collateral and borrows real assets against it.

Sanity checks that only compare the oracle's latest price with its own previous updates do not help if the manipulated price persists across several updates, which is easy to achieve when nobody else trades the asset.

## Exploit Scenario

Alice runs a lending pool that accepts a thinly traded token as collateral and reads its price from a single oracle. Bob places a sell order for the token at about 100 times its normal price and fills it from a second account. The oracle reports the inflated price, and Bob uses a small amount of the token to borrow most of the pool's reserves.

This is how the YieldBlox DAO pool on Stellar was drained of about $10.2 million in February 2026: a trade in the illiquid USTRY/USDC market raised USTRY's reported price from about $1.05 to about $106, and the attacker borrowed about 61 million XLM and 1 million USDC against it.

## Example

```rust
#[contractimpl]
impl Lending {
    pub fn borrow(env: Env, user: Address, collateral_asset: Address, amount: i128) {
        user.require_auth();
        let oracle: Address = env.storage().instance().get(&DataKey::Oracle).unwrap();
        // BUG: single, unvalidated price from a feed that follows a thin market
        let price = PriceFeedClient::new(&env, &oracle).lastprice(&collateral_asset).unwrap().price;

        let collateral: i128 = env.storage().persistent().get(&DataKey::Collateral(user.clone())).unwrap_or(0);
        let max_debt = collateral * price * LTV_BPS / 10_000;
        let debt: i128 = env.storage().persistent().get(&DataKey::Debt(user.clone())).unwrap_or(0);
        if debt + amount > max_debt {
            panic!("undercollateralized");
        }
        env.storage().persistent().set(&DataKey::Debt(user), &(debt + amount));
    }
}
```

## Mitigations

- Only accept collateral that has enough liquidity to make price manipulation expensive, and cap the total value that can be borrowed against each asset.
- Cross-check the price against an independent source, and reject prices that are stale, non-positive, or too far from the reference:

```rust
fn fresh_price(env: &Env, oracle: &Address, asset: &Address) -> i128 {
    let data = PriceFeedClient::new(env, oracle).lastprice(asset).expect("no price");
    if data.price <= 0 || env.ledger().timestamp() > data.timestamp + MAX_PRICE_AGE {
        panic!("stale or invalid price");
    }
    data.price
}

// In `borrow`:
let price = fresh_price(&env, &oracle, &collateral_asset);
let reference_price = fresh_price(&env, &reference, &collateral_asset);
if (price - reference_price).abs() * 10_000 > reference_price * MAX_DEVIATION_BPS {
    panic!("price deviation too high");
}
```

- Prefer time-weighted prices over longer windows, and limit how fast the accepted price can change.
- Monitor the markets that collateral prices come from, and be able to pause borrowing.

## References

- [BlockSec: YieldBlox DAO incident on Stellar](https://blocksec.com/blog/yieldblox-dao-incident-on-stellar-oracle-misconfiguration-enabled-a-10m-drain)
- [Halborn: Explained: The YieldBlox hack](https://www.halborn.com/blog/post/explained-the-yieldblox-hack-february-2026)
