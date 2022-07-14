# Messages priority

Some message types may be more important than others and should have priority over them. That is, the more significant message type is, the more quickly it should be included in a block, before other messages are.

Failing to prioritize message types allows attackers to front-run them, possibly gaining unfair adventage. Moreover, during high network congestion, the message may be simply not included in a block for a long period, causing the system to malfunction.

In the Cosmos's mempool, transactions are [ordered in first-in-first-out (FIFO) manner](https://github.com/tendermint/tendermint/blob/master/docs/architecture/adr-067-mempool-refactor.md#context) by default. Especially, there is no fee-based ordering.

## Example

An example application implements a lending platform. It uses a price oracle mechanism, where privileged entities can vote on new assets' prices. The mechanism is implemented as standard messages.

```go
service Msg {
  rpc Lend(MsgLend) returns (MsgLendResponse);

  rpc Borrow(MsgBorrow) returns (MsgBorrowResponse);

  rpc Liquidate(MsgLiquidate) returns (MsgLiquidateResponse);

  rpc OracleCommitPrice(MsgOracleCommitPrice) returns (MsgOracleCommitPriceResponse);

  rpc OracleRevealPrice(MsgOracleRevealPrice) returns (MsgOracleRevealPriceResponse);
}
```

Prices ought to be updated (commited and revealed) after every voting period. However, an attacker can spam the network with low-cost transactions to completely fill blocks, leaving no space for price updates. He can then profit from the fact that the system uses outdated, stale prices.

## Example 2

Lets consider a liquidity pool application that implements the following message types:

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

There is the `Pause` message, which allows privileged users to stop the pool.

Once a bug in pool's implementation is discovered, attackers and the pool's operators will compete for whos message is first executed (`Swap` vs `Pause`). Prioritizing `Pause` messages will help pool's operators to prevent exploitation, but in this case it won't stop the attackers completely. They can outrun the `Pause` message by order of magnitude - so the priority will not matter -  or even cooperate with a malicious validator node - who can order his mempool in arbitrary way.


## Mitigations

- [Use `CheckTx`'s `priority` return value](https://docs.tendermint.com/master/spec/abci/abci.html#checktx-2) to prioritize messages. Please note that this feature has a transaction (not a message) granuality - users can send multiple messages in a single transactions, and it is the tx that will have to be prioritized.

## External examples
- [Terra Money's oracle messages were not prioritized](https://cryptorisks.substack.com/p/ust-december-2021) (search for "priority"). It was [fixed with modifications to Tendermint](https://github.com/terra-money/tendermint/commit/6805b4866bdbd6933000eb0e761acbf15edd8ed6).
- [Umee oracle and orchestrator messages were not prioritized](https://github.com/trailofbits/publications/blob/master/reviews/Umee.pdf) (search for finding TOB-UMEE-20 and TOB-UMEE-31).
