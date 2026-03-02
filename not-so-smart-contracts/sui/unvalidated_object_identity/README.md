# Unvalidated Shared Object Identity

Functions that accept shared objects by type without verifying object ID allow attackers to substitute fake instances.

## Description

In Sui Move, functions accept objects by type rather than by address. Any shared object matching the expected type can be passed as an argument by any caller. Unlike the EVM, where contract addresses are typically hardcoded, Sui functions implicitly trust that the caller provides the correct object instance. If a function accepts `&mut Pool<A, B>` without verifying the object's ID matches the expected instance, an attacker can create their own `Pool<A, B>` with manipulated reserves and pass it in place of the legitimate one, leading to skewed exchange rates, incorrect accounting, or loss of funds.

## Exploit Scenario

Alice deploys a DEX router that accepts a `Pool<SUI, USDC>` shared object reference for executing swaps. The router validates its own version but never checks the pool's object ID. Bob creates a fake `Pool<SUI, USDC>` with near-zero USDC reserves. Bob calls the router's `swap` function, passing his fake pool instead of the legitimate one. The `calculate_output` function returns an inflated amount based on the manipulated reserves, and Bob drains real liquidity from the system.

## Example

A DEX router executes swaps through a pool and a fee configuration, both passed as shared object references. The router validates its own version but never checks that the pool is the correct instance:

```move
public fun swap<A, B>(
    router: &mut Router,
    pool: &mut Pool<A, B>,
    coin_in: Coin<A>,
    ctx: &mut TxContext,
) {
    router::assert_version(router);
    // BUG: no validation that `pool` is the correct instance
    let amount_out = pool::calculate_output(pool, coin::value(&coin_in));
    let coin_out = pool::do_swap(pool, coin_in, ctx);
    transfer::public_transfer(coin_out, tx_context::sender(ctx));
}
```

## Mitigations

- Store the expected object ID of each dependency inside the parent object (e.g., `router.pool_id`) and validate with `assert!(object::id(pool) == router.pool_id)` on every entry point.
- Never assume the caller provides the correct object instance; treat all shared object parameters as untrusted input and validate them against stored references before performing any state-changing operations.
