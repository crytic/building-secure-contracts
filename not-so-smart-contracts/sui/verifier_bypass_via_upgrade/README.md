# Verifier Bypass via Package Upgrade

Adding the `key` ability to a struct during a package upgrade bypasses Sui's `id_leak_verifier` checks on prior versions.

## Description

Sui's `id_leak_verifier` ensures that the `id` field of any struct with the `key` ability originates from `object::new()` and is never transferred between different struct types. This prevents object identity spoofing at the bytecode level. However, the verifier only enforces this rule on structs that currently possess the `key` ability -- structs without `key` are free to pack arbitrary UIDs without restriction.

Sui's upgrade model historically allowed adding abilities (including `key`) to existing structs during a package upgrade. Combined with Programmable Transaction Blocks (PTBs), which can invoke functions from different package versions in the same transaction, an attacker can exploit the gap: publish V0 with a struct that lacks `key` and a helper function that packs it from any UID, upgrade to V1 adding `key` to that struct (and removing the helper), then use a PTB to call V0's helper (still on-chain) to mint a forged object and pass it into V1's functions as a legitimate Sui object. The verifier is bypassed because V0's bytecode was validated without `key` checks on the struct.

## Exploit Scenario

Alice publishes package V0 containing a `Bar` struct with only the `store` ability and a public function `build_bar_from_foo` that packs a `Bar` from an arbitrary UID. Alice then upgrades to V1, adding `key` to `Bar` and removing the helper function. Bob constructs a Programmable Transaction Block that calls V0's `build_bar_from_foo` (still deployed on-chain) to forge a `Bar` with a copied UID, then passes this forged object into V1's `take_bar` function. The runtime accepts it as a valid Sui object because `Bar` now has `key` in V1, allowing Bob to spoof object identity.

## Example

```move
// === V0: Bar has no `key`, so the verifier ignores UID reuse ===
module example::token {
    use sui::object::{Self, UID};
    use sui::tx_context::TxContext;

    struct Foo has key { id: UID, value: u64 }
    struct Bar has store { id: UID, value: u64 }

    // Verifier allows this because Bar is not a Sui object
    public fun build_bar_from_foo(foo: &Foo, ctx: &mut TxContext): Bar {
        Bar { id: object::new(ctx), value: foo.value }
        // A malicious version could copy foo.id directly into Bar
    }
}

// === V1: Bar gains `key`, build_bar_from_foo is removed ===
module example::token {
    use sui::object::UID;

    struct Foo has key { id: UID, value: u64 }
    struct Bar has key, store { id: UID, value: u64 }

    public fun take_bar(bar: Bar): u64 {
        let Bar { id, value } = bar;
        object::delete(id);
        value
    }
}

// === Attack via PTB (pseudocode) ===
// 1. Call V0::example::token::build_bar_from_foo(foo) -> bar
// 2. Call V1::example::token::take_bar(bar)
// The runtime accepts `bar` as a valid Sui object because Bar
// now has `key` in V1, even though it was forged in V0.
```

## Mitigations

- The Sui framework now prevents adding the `key` ability to a struct during package upgrades, closing this attack vector at the platform level.
- Set the upgrade policy to `immutable` when the package is finalized and no further upgrades are needed.
- Use the most restrictive upgrade policy available (`additive` or `dep_only`) to limit what changes an upgrade can introduce.
- Audit all struct ability changes during upgrade reviews; any addition of `key` or `store` to a previously ability-less struct should be treated as a red flag.
- Avoid publishing helper functions that pack structs from caller-supplied UIDs, even when the struct currently lacks `key`.
