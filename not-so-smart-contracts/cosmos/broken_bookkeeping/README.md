# Handling Broken Bookkeeping

The `x/bank` module is the standard way to manage tokens in applications based on the Cosmos SDK. It allows minting, burning, and transferring coins between both user accounts and module accounts. If an application uses its own internal bookkeeping, it must carefully utilize the `x/bank` features.

## Example

An application enforces the following invariant as a sanity check: the amount of tokens owned by a module equals the amount of tokens deposited by users via the custom `x/hodl` module.

```go
func BalanceInvariant(k Keeper) sdk.Invariant {
    return func(ctx sdk.Context) (string, bool) {
        weAreFine := true
        msg := "hodling hard"

        weHold := k.bankKeeper.SpendableCoins(authtypes.NewModuleAddress(types.ModuleName)).AmountOf("BTC")
        usersDeposited := k.GetTotalDeposited("BTC")

        if weHold != usersDeposited {
            msg = fmt.Sprintf("%dBTC missing! Halting chain.\n", usersDeposited - weHold)
            weAreFine = false
        }

        return sdk.FormatInvariant(types.ModuleName, "hodl-balance",), weAreFine
    }
}
```

A malicious user can simply transfer a tiny amount of BTC tokens directly to the `x/hodl` module via a message to the `x/bank` module. This would bypass the accounting of the `x/hodl`, and the `GetTotalDeposited` function would report an outdated amount, smaller than the module's `SpendableCoins`.

Since an invariant's failure stops the chain, this bug represents a simple Denial-of-Service attack vector.

## Example 2

Suppose an application implements a lending platform, allowing users to deposit Tokens in exchange for xTokens - similar to [Compound's cTokens](https://compound.finance/docs/ctokens#exchange-rate). The Token:xToken exchange rate is calculated as `(amount of Tokens borrowed + amount of Tokens held by the module account) / (amount of uTokens in circulation)`.

The implementation of the `GetExchangeRate` method for computing an exchange rate is presented below.

```go
func (k Keeper) GetExchangeRate(tokenDenom string) sdk.Coin {
    uTokenDenom := createUDenom(tokenDenom)

    tokensHeld := k.bankKeeper.SpendableCoins(authtypes.NewModuleAddress(types.ModuleName)).AmountOf(tokenDenom).ToDec()
    tokensBorrowed := k.GetTotalBorrowed(tokenDenom)
    uTokensInCirculation := k.bankKeeper.GetSupply(uTokenDenom).Amount

    return (tokensHeld + tokensBorrowed) / uTokensInCirculation
}

```

A malicious user can manipulate the exchange rate in two ways:

- by force-sending Tokens to the module, changing the `tokensHeld` value
- by transferring uTokens to another chain via IBC, changing the `uTokensInCirculation` value

The first "attack" could be executed by sending a [`MsgSend`](https://docs.cosmos.network/main/modules/bank#msgsend) message but would likely be unprofitable, as it would irreversibly decrease the attacker's resources.

The second attack works because the IBC module [burns transferred coins in the source chain](https://github.com/cosmos/ibc-go/blob/48a6ae512b4ea42c29fdf6c6f5363f50645591a2/modules/apps/transfer/keeper/relay.go#L135-L136) and mints corresponding tokens in the destination chain. As a result, the supply reported by the `x/bank` module decreases, increasing the exchange rate. The malicious user can then easily transfer back the uTokens.

## Mitigations

- Use [`Blocklist`](https://docs.cosmos.network/v0.45/modules/bank/02_keepers.html#blocklisting-addresses) to prevent unexpected token transfers to specific addresses
- Use [`SendEnabled`](https://docs.cosmos.network/v0.45/modules/bank/05_params.html#parameters) parameter to prevent unexpected transfers of specific tokens (denominations)
- Ensure that the blocklist is explicitly checked [whenever a new functionality allowing for token transfers is implemented](https://github.com/cosmos/cosmos-sdk/issues/8463#issuecomment-801046285)

## External examples

- [Umee was vulnerable to token:uToken exchange rate manipulation](https://github.com/trailofbits/publications/blob/master/reviews/Umee.pdf) (search for finding TOB-UMEE-21)
- [Desmos incorrectly blocklisted addresses](https://github.com/desmos-labs/desmos/blob/e3c89e2f9ddd5dfde5d11c3ad5319e3c249cacb3/CHANGELOG.md#version-0154) (check app.go file in [the commits diff](https://github.com/desmos-labs/desmos/compare/v0.15.3...v0.15.4))
