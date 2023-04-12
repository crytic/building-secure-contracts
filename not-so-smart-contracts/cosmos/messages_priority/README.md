# Prioritizing Messages

Some message types may be more important than others and should have priority over them. In other words, the more significant a message type is, the more quickly it should be included in a block, before other messages.

Failing to prioritize message types enables attackers to front-run them, potentially gaining an unfair advantage. Additionally, during high network congestion, the message may not be included in a block for an extended period, causing the system to malfunction.

By default, transactions in Cosmos's mempool are [ordered in a first-in-first-out (FIFO) manner](https://github.com/tendermint/tendermint/blob/f9e0f77af333f4ab7bfa1c0c303f7db47cec0c9e/docs/architecture/adr-067-mempool-refactor.md#context). Notably, there is no fee-based ordering.

## Example

Consider an application that implements a lending platform. It uses a price oracle mechanism, where privileged entities can vote on new assets' prices. The mechanism is implemented as standard messages.

```go
service Msg {
  rpc Lend(MsgLend) returns (MsgLendResponse);

  rpc Borrow(MsgBorrow) returns (MsgBorrowResponse);

  rpc Liquidate(MsgLiquidate) returns (MsgLiquidateResponse);

  rpc OracleCommitPrice(MsgOracleCommitPrice) returns (MsgOracleCommitPriceResponse);

  rpc OracleRevealPrice(MsgOracleRevealPrice) returns (MsgOracleRevealPriceResponse);
}
```

Prices should be updated (committed and revealed) after every voting period. However, an attacker can spam the network with low-cost transactions to completely fill blocks, leaving no space for price updates. The attacker can then profit from the fact that the system uses outdated, stale prices.

## Example 2

Consider a liquidity pool application that implements the following message types:

```go
service Msg {
  rpc CreatePool(MsgCreatePool) returns (MsgCreatePoolResponse);

  rpc Deposit(MsgDeposit) returns (MsgDepositResponse);

  rpc Withdraw(MsgWithdraw) returns (MsgWithdrawResponse);

  rpc Swap(MsgSwap) returns (MsgSwapResponse);

  rpc Pause(MsgPause) returns (MsgPauseResponse);

  rpc Resume(MsgResume) returns (MsgResumeResponse);
}
```

The `Pause` message allows privileged users to stop the pool.

When a bug is discovered in the pool's implementation, attackers and the pool's operators compete to determine whose message is executed first (`Swap` vs `Pause`). Prioritizing `Pause` messages helps pool operators prevent exploitation, but in this case, it doesn't completely stop the attackers. They can outrun the `Pause` message by an order of magnitude, rendering the priority irrelevant or even collaborate with a malicious validator node, which can order its mempool arbitrarily.

## Mitigations

- [Use the `CheckTx`'s `priority` return value](https://github.com/tendermint/spec/blob/v0.7.1/spec/abci/abci.md#checktx-1) to prioritize messages. Note that this feature has transaction (not message) granularity: users can send multiple messages in a single transaction, and the transaction must be prioritized.
- Perform authorization for prioritized transactions as early as possible, preferably during the `CheckTx` phase. This prevents attackers from filling entire blocks with invalid but prioritized transactions. In other words, implement a mechanism that prevents validators from accepting unauthorized, prioritized messages into a mempool.
- Alternatively, charge a high fee for prioritized transactions to disincentivize attackers.

## External Examples

- [Terra Money's oracle messages were not prioritized](https://cryptorisks.substack.com/p/ust-december-2021) (search for "priority"). The issue was [resolved with modifications to Tendermint](https://github.com/terra-money/tendermint/commit/6805b4866bdbd6933000eb0e761acbf15edd8ed6).
- [Umee oracle and orchestrator messages were not prioritized](https://github.com/trailofbits/publications/blob/master/reviews/Umee.pdf) (search for finding TOB-UMEE-20 and TOB-UMEE-31).
