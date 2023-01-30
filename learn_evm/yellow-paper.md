
# Ethereum Yellow Paper

So, you want to read the yellow paper. Before we dive in, keep in mind that the yellow paper is out of date and some in the community might refer to it as being depreciated. Check out the [BRANCHES.md](https://github.com/ethereum/yellowpaper/blob/master/BRANCHES.md) file of the [`yellowpaper` repository on github](https://github.com/ethereum/yellowpaper) to stay up-to-date on how closely this document tracks the latest version of the Ethereum protocol. At the time of writing, the yellow paper is up to date with the Berlin hardfork which occurred in April 2021. For an overview of all Ethereum forks and which EIPs are included in each of them, see the [EIPs Forks](./eips_forks.md) page.

For a more up-to-date reference, check out the [Ethereum Specification](https://ethereum.github.io/execution-specs/autoapi/ethereum/) which features a detailed description of each opcode *for each hardfork* in addition to reference implementations written in python.

That said, the yellow paper is still a rich resource for ramping up on the fundamentals of the Ethereum protocol. This document aims to provide some guidance and assistance in deciphering Ethereum's flagship specification.

## Mathematical Symbols

One challenging part of the yellow paper, for those of us who are not so well trained in formal mathematics, is comprehending the mathematical symbols. A cheat-sheet of some of these symbols is provided below

 - `∃`: there exists
 - `∀`: for all
 - `∧`: and
 - `∨`: or

And some more Ethereum-specific symbols:

 - `N_{H}`: 1,150,000 aka block number at which the protocol was upgraded from homestead to frontier.
 - `T`: a transaction eg `T = { n: nonce, p: gasPrice, g: gasLimit, t: to, v: value, i: initBytecode, d: data }`
 - `S()`: returns the sender of a transaction eg `S(T) = T.from`
 - `Λ`: (lambda) account creation function
 - `KEC`: Keccak SHA-3 hash function
 - `RLP`: Recursive Length Prefix encoding

## High-level glossary

The following are symbols and function representations that provide a high-level description of ethereum. Many of these symbols represent a data structure, the details of which are described in subsequent sections.

 - `σ`: ethereum world state
 - `B`: block
 - `μ`: EVM state
 - `A`: accumulated transaction sub-state
 - `I`: execution environment
 - `o`: output of `H(μ,I)` ie null if we're good to go or a set of data if execution should halt
 - `Υ(σ,T) => σ'`: the transaction-level state transition function
 - `Π(σ,B) => σ'`: the block-level state transition function, processes all transactions then finalizes with Ω
 - `Ω(B,σ) => σ`: block-finalisation state transition function
 - `O(σ,μ,A,I)`: one iteration of the execution cycle
 - `H(μ,I) => o`: outputs null while execution should continue or a series if execution should halt.

## Ethereum World-State: σ

A mapping between addresses (external or contract) and account states. Saved as a Merkle-Patricia tree whose root is recorded on the blockchain backbone.

```
σ = [ account1={...}, account2={...},
  account3= {
    n: nonce aka number of transactions sent by account3
    b: balance ie number of wei account3 controls
    s: storage root, hash of the merkle-patricia tree that contains this accounts long-term data store
    c: code, hash of the EVM bytecode that controls this account. If this equals the hash of an empty string, this is a non-contract account.
  }, ...
]
```

## The Block: B

```
B = Block = {
  H: Header = {
    p: parentHash,
    o: ommersHash,
    c: beneficiary,
    r: stateRoot,
    t: transactionsRoot,
    e: receiptsRoot,
    b: logsBloomFilter,
    d: difficulty,
    i: number,
    l: gasLimit,
    g: gasUsed,
    s: timestamp,
    x: extraData,
    m: mixHash,
    n: nonce,
  },
  T: Transactions = [
    tx1, tx2...
  ],
  U: Uncle block headers = [
    header1, header2..
  ],
  R: Transaction Receipts = [
    receipt_1 = {
      σ: root hash of the ETH state after transaction 1 finishes executing,
      u: cumulative gas used immediately after this tx completes,
      b: bloom filter,
      l: set of logs created while executing this tx
    }
  ]
}
```

## Execution Environment: I

```
I = Execution Environment = {
  a: address(this) address of the account which owns the executing code
  o: tx.origin original sender of the tx that initialized this execution
  p: tx.gasPrice price of gas
  d: data aka byte array of method id & args
  s: sender of this tx or initiator of this execution
  v: value send along w this execution or transaction
  b: byte array of machine code to be executed
  H: header of the current block
  e: current stack depth
}
```

## EVM state: μ

The state of the EVM during execution. This is the data structure provided by the `debug_traceTransaction` JSON RPC method, see [this page](./tracing.md) for more details about using this method to investigate transaction execution.

```
μ = {
  g: gas left
  pc: program counter ie index into which instruction of I.b to execute next
  m: memory contents, lazily initialized to 2^256 zeros
  i: number of words in memory
  s: stack contents
}
```

## Accrued sub-state: A

The data accumulated during tx execution that needs to be available at the end to finalize the transactions state changes.

```
A = {
  s: suicide set ie the accounts to delete at the end of this tx
  l: logs
  t: touched accounts
  r: refunds eg gas received when storage is freed
}
```

## Contract Creation

If we send a transaction `tx` to create a contract, `tx.to` is set to `null` and we include a `tx.init` field that contains bytecode. This is NOT the bytecode run by the contract, rather it RETURNS the bytecode run by the contract ie the `tx.init` code is run ONCE at contract creation and never again.

If `T.to == 0` then this is a contract creation transaction and `T.init != null`, `T.data == null`
