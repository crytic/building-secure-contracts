# Configuration options

The following is a list of all the options that may be provided in the Echidna
configuration file. Whenever an option can also be set via the command line, the
CLI equivalent flag is provided as a reference. Some flags are relatively new
and only available on recent Echidna builds; in those cases, the minimum Echidna
version required to use the feature is indicated in the table.

### `testMode`

| Type   | Default      | Available in | CLI equivalent     |
| ------ | ------------ | ------------ | ------------------ |
| String | `"property"` | \*           | `--test-mode MODE` |

The test mode to run. It should be one of the following items:

- `"property"`: Run user-defined property tests.
- `"assertion"`: Detect assertion failures (previously `checkAsserts`).
- `"optimization"`: Find the maximum value for a function.
- `"overflow"`: Detect integer overflows (only available in Solidity 0.8.0 or greater).
- `"exploration"`: Run contract code without executing any tests.

Review the [testing modes tutorial](./basic/testing-modes.md) to select the one
most suitable to your project.

### `testLimit`

| Type | Default | Available in | CLI equivalent   |
| ---- | ------- | ------------ | ---------------- |
| Int  | `50000` | \*           | `--test-limit N` |

Number of transactions to generate during testing. The campaign will stop when
the `testLimit` is reached or if a `timeout` is set and the execution time
exceeds it.

### `seqLen`

| Type | Default | Available in | CLI equivalent |
| ---- | ------- | ------------ | -------------- |
| Int  | `100`   | \*           | `--seq-len N`  |

Number of transactions that a transaction sequence will have during testing, and
maximum length of transaction sequences in the corpus. After every N
transactions, Echidna will reset the EVM to the initial post-deployment state.

### `timeout`

| Type | Default | Available in | CLI equivalent |
| ---- | ------- | ------------ | -------------- |
| Int  | `null`  | \*           | `--timeout N`  |

Campaign timeout, in seconds. By default it is not time-limited. If a value is
set, the campaign will stop when the time is exhausted or the `testLimit` is
reached, whichever happens first.

### `seed`

| Type | Default | Available in | CLI equivalent |
| ---- | ------- | ------------ | -------------- |
| Int  | random  | \*           | `--seed N`     |

Seed used for random value generation. By default it is a random integer. The
seed may not guarantee reproducibility if multiple `workers` are used, as the
operating system thread scheduling may introduce additional randomness into the
process.

### `shrinkLimit`

| Type | Default | Available in | CLI equivalent    |
| ---- | ------- | ------------ | ----------------- |
| Int  | `5000`  | \*           | `-shrink-limit N` |

Number of attempts to shrink a failing sequence of transactions.

### `contractAddr`

| Type    | Default                                           | Available in | CLI equivalent         |
| ------- | ------------------------------------------------- | ------------ | ---------------------- |
| Address | `"0x00a329c0648769a73af` `ac7f9381e08fb43dbea72"` | \*           | `--contract-addr ADDR` |

Address to deploy the contract to test.

### `coverage`

| Type | Default | Available in |
| ---- | ------- | ------------ |
| Bool | `true`  | \*           |

Enable the use of coverage-guided fuzzing and corpus collection. We recommend
keeping this enabled.

### `corpusDir`

| Type   | Default | Available in | CLI equivalent      |
| ------ | ------- | ------------ | ------------------- |
| String | `null`  | \*           | `--corpus-dir PATH` |

Directory to save the corpus collected (requires coverage enabled).

### `deployer`

| Type    | Default     | Available in | CLI equivalent |
| ------- | ----------- | ------------ | -------------- |
| Address | `"0x30000"` | \*           | `--deployer`   |

Address of the deployer of the contract to test.

### `deployContracts`

| Type                    | Default | Available in |
| ----------------------- | ------- | ------------ |
| [⁠[⁠Address, String⁠]⁠] | `[]`    | 2.0.2+       |

Addresses and contract names to deploy using the available source code. The
deployer address is the same as the contract to test. Echidna will error if the
deployment fails.

### `deployBytecodes`

| Type                    | Default | Available in |
| ----------------------- | ------- | ------------ |
| [⁠[⁠Address, String⁠]⁠] | `[]`    | 2.0.2+       |

Addresses and bytecodes to deploy. The deployer address is the same as the
contract to test. Echidna will error if the deployment fails.

### `sender`

| Type      | Default                             | Available in | CLI equivalent |
| --------- | ----------------------------------- | ------------ | -------------- |
| [Address] | `["0x10000", "0x20000", "0x30000"]` | \*           | `--sender`     |

List of addresses to (randomly) use as `msg.sender` for the transactions sent
during testing. These addresses are used as the sender for all transactions
produced by Echidna, except for property evaluation in `property` mode (see
`psender` below).

### `psender`

| Type    | Default     | Available in |
| ------- | ----------- | ------------ |
| Address | `"0x10000"` | \*           |

Address of `msg.sender` to use for property evaluation. This address is only
used to evaluate properties (functions with the configured `prefix`) while
executing Echidna in `property` mode.

### `prefix`

| Type   | Default      | Available in |
| ------ | ------------ | ------------ |
| String | `"echidna_"` | \*           |

Prefix of the function names used as properties in the contract to test.

### `propMaxGas`

| Type | Default                                | Available in |
| ---- | -------------------------------------- | ------------ |
| Int  | `12500000` (current max gas per block) | \*           |

Maximum amount of gas to consume when running function properties. If a property
runs out of gas, it will be considered as a failure.

### `testMaxGas`

| Type | Default                                | Available in |
| ---- | -------------------------------------- | ------------ |
| Int  | `12500000` (current max gas per block) | \*           |

Maximum amount of gas to consume when running random transactions. A
non-property transaction that runs out of gas (e.g. a transaction in assertion
mode) will not be considered a failure.

### `maxGasprice`

| Type | Default | Available in |
| ---- | ------- | ------------ |
| Int  | `0`     | \*           |

Maximum amount of gas price to randomly use in transactions. Do not change it
unless you absolutely need it.

### `maxTimeDelay`

| Type | Default             | Available in |
| ---- | ------------------- | ------------ |
| Int  | `604800` (one week) | \*           |

Maximum amount of seconds of delay between transactions.

### `maxBlockDelay`

| Type | Default | Available in |
| ---- | ------- | ------------ |
| Int  | `60480` | \*           |

Maximum amount of block numbers between transactions.

### `solcArgs`

| Type   | Default | Available in | CLI equivalent     |
| ------ | ------- | ------------ | ------------------ |
| String | `""`    | \*           | `--solc-args ARGS` |

Additional arguments to use in `solc` for compiling the contract to test.

### `cryticArgs`

| Type     | Default | Available in | CLI equivalent       |
| -------- | ------- | ------------ | -------------------- |
| [String] | `[]`    | \*           | `--crytic-args ARGS` |

Additional arguments to use in `crytic-compile` for compiling the contract to
test.

### `quiet`

| Type | Default | Available in |
| ---- | ------- | ------------ |
| Bool | `false` | \*           |

Hide `solc` stderr output and additional information during the testing.

### `format`

| Type   | Default | Available in | CLI equivalent    |
| ------ | ------- | ------------ | ----------------- |
| String | `null`  | \*           | `--format FORMAT` |

Select a textual output format. By default, interactive TUI is run or text if a
terminal is absent.

- `"text"`: simple textual interface.
- `"json"`: JSON output.
- `"none"`: no output.

### `balanceContract`

| Type | Default | Available in |
| ---- | ------- | ------------ |
| Int  | `0`     | \*           |

Initial Ether balance of `contractAddr`. See our tutorial on [working with
ETH](./basic/working-with-eth.md) for more details.

### `balanceAddr`

| Type | Default      | Available in |
| ---- | ------------ | ------------ |
| Int  | `0xffffffff` | \*           |

Initial Ether balance of `deployer` and each of the `sender` accounts. See our
tutorial on [working with ETH](./basic/working-with-eth.md) for more details.

### `maxValue`

| Type | Default                           | Available in |
| ---- | --------------------------------- | ------------ |
| Int  | `100000000000000000000` (100 ETH) | \*           |

Max amount of value in each randomly generated transaction. See our tutorial on
[working with ETH](./basic/working-with-eth.md) for more details.

### `testDestruction`

| Type | Default | Available in |
| ---- | ------- | ------------ |
| Bool | `false` | \*           |

Add a special test that fails if a contract is self-destructed.

### `stopOnFail`

| Type | Default | Available in |
| ---- | ------- | ------------ |
| Bool | `false` | \*           |

Stops the fuzzing campaign when the first test fails.

### `allContracts`

| Type | Default | Available in                    | CLI equivalent    |
| ---- | ------- | ------------------------------- | ----------------- |
| Bool | `false` | 2.1.0+ (previously `multi-abi`) | `--all-contracts` |

Makes Echidna fuzz the provided test contracts and any other deployed contract
whose ABI is known at runtime.

### `filterBlacklist`

| Type | Default | Available in |
| ---- | ------- | ------------ |
| Bool | `true`  | \*           |

Allows Echidna to avoid calling (when set to true) or only call (when set to
false) a set of functions. The function allowlist or denylist should be provided
in `filterFunctions`.

### `filterFunctions`

| Type     | Default | Available in |
| -------- | ------- | ------------ |
| [String] | `[]`    | \*           |

Configures the function allowlist or denylist from `filterBlacklist`. The list
should contain strings in the format of
`"Contract.functionName(uint256,uint256)"` following the signature convention.

### `allowFFI`

| Type | Default | Available in |
| ---- | ------- | ------------ |
| Bool | `false` | 2.1.0+       |

Allows the use of the HEVM `ffi` cheatcode.

### `rpcUrl`

| Type   | Default | Available in                                | CLI equivalent  | Env. variable equivalent |
| ------ | ------- | ------------------------------------------- | --------------- | ------------------------ |
| String | `null`  | 2.1.0+ (env), 2.2.0+ (config), 2.2.3+ (cli) | `--rpc-url URL` | `ECHIDNA_RPC_URL`        |

URL to fetch contracts over RPC.

### `rpcBlock`

| Type   | Default | Available in                                | CLI equivalent  | Env. variable equivalent |
| ------ | ------- | ------------------------------------------- | --------------- | ------------------------ |
| String | `null`  | 2.1.0+ (env), 2.2.0+ (config), 2.2.3+ (cli) | `--rpc-block N` | `ECHIDNA_RPC_BLOCK`      |

Block number to use when fetching over RPC.

### `etherscanApiKey`

| Type   | Default | Available in                  | Env. variable equivalent |
| ------ | ------- | ----------------------------- | ------------------------ |
| String | `null`  | 2.1.0+ (env), 2.2.4+ (config) | `ETHERSCAN_API_KEY`      |

Etherscan API key used to fetch contract code.

### `coverageFormats`

| Type     | Default                 | Available in |
| -------- | ----------------------- | ------------ |
| [String] | `["txt","html","lcov"]` | 2.2.0+       |

List of file formats to save coverage reports in; default is all possible
formats.

### `workers`

| Type | Default | Available in | CLI equivalent |
| ---- | ------- | ------------ | -------------- |
| Int  | `1`     | 2.2.0+       | `--workers`    |

Number of workers.

### `server`

| Type | Default | Available in | CLI equivalent  |
| ---- | ------- | ------------ | --------------- |
| Int  | `null`  | 2.2.2+       | `--server PORT` |

Run events server on the given port.

### `symExec`

| Type | Default | Available in |
| ---- | ------- | ------------ |
| Bool | `false` | 2.2.4+       |

Whether to add an additional symbolic execution worker.

### `symExecConcolic`

| Type | Default | Available in |
| ---- | ------- | ------------ |
| Bool | `true`  | 2.2.4+       |

Whether symbolic execution will be concolic (vs full symbolic execution). Only
relevant if `symExec` is true.

### `symExecNSolvers`

| Type | Default | Available in |
| ---- | ------- | ------------ |
| Int  | `1`     | 2.2.4+       |

Number of SMT solvers used in symbolic execution. While there is a single
symExec worker, N threads may be used to solve SMT queries. Only relevant if
`symExec` is true.

### `symExecTimeout`

| Type | Default | Available in |
| ---- | ------- | ------------ |
| Int  | `30`    | 2.2.4+       |

Timeout for symbolic execution SMT solver. Only relevant if `symExec` is true.
When the SMT solver used is Z3, this timeout applies per query, and is not
global.

### `symExecMaxIters`

| Type | Default | Available in |
| ---- | ------- | ------------ |
| Int  | `10`    | 2.2.4+       |

Number of times we may revisit a particular branching point. Only relevant if
`symExec` is true and `symExecConcolic` is false.

### `symExecAskSMTIters`

| Type | Default | Available in |
| ---- | ------- | ------------ |
| Int  | `1`     | 2.2.4+       |

Number of times we may revisit a particular branching point before we consult
the smt solver to check reachability. Only relevant if `symExec` is true and
`symExecConcolic` is false.

## Experimental options

There are some options in Echidna that are meant for advanced debugging and
experimenting. Those are listed below.

### `estimateGas`

| Type | Default | Available in |
| ---- | ------- | ------------ |
| Bool | `false` | \*           |

Enables the collection of worst-case gas usage. The information is stored as
part of the corpus on the `gas_info` field. This functionality is experimental.

### `dictfreq`

| Type  | Default | Available in |
| ----- | ------- | ------------ |
| Float | `0.40`  | \*           |

This parameter controls how often Echidna uses its internal dictionary versus a
random value when generating a transaction. We do not recommend changing the
default value.

### `mutConsts`

| Type  | Default        | Available in |
| ----- | -------------- | ------------ |
| [Int] | `[1, 1, 1, 1]` | \*           |

Echidna uses weighted probabilities to pick a mutator for a transaction
sequence. This parameter configures the weights for each kind of mutation. The
value consists of four integers, `[c1, c2, c3, c4]`. Refer to the
[implementation
code](https://github.com/crytic/echidna/blob/8d20836c4a5bba6779c7a5b58cc7907c89a4e581/lib/Echidna/Mutator/Corpus.hs#L70-L101)
for their meaning and impact. We do not recommend changing the default value.

## Deprecated options

There are some options in Echidna that have been deprecated and will be removed soon. Those are listed below.

### `initialize`

| Type   | Default | Available in |
| ------ | ------- | ------------ |
| String | `null`  | \*           |

This allows initializing the chain state in Echidna with a series of
transactions, typically captured with [Etheno](https://github.com/crytic/etheno). Nowadays, with the
introduction of on-chain fuzzing in Echidna, it has become deprecated.
