# Configuration options

<style>table {margin: 0}</style>

The following is a list of all the options that may be provided in the Echidna configuration file.

## `testMode`

Type | Default | Available in
-----|---------|-------------
String | `"property"` | *

The test mode to run. It should be one of the following items:

* `"property"`: Run user-defined property tests.
* `"assertion"`: Detect assertion failures (previously `checkAsserts`).
* `"optimization"`: Find the maximum value for a function.
* `"overflow"`: Detect integer overflows (only available in Solidity 0.8.0 or greater).
* `"exploration"`: Run contract code without executing any tests.

## `testLimit`

Type | Default | Available in
-----|---------|-------------
Int  | `50000` | *

Number of sequences of transactions to generate during testing.

## `seqLen`

Type | Default | Available in
-----|---------|-------------
Int  | `100`   | *

Number of transactions to generate during testing.

## `shrinkLimit`

Type | Default | Available in
-----|---------|-------------
Int  | `5000`  | *

Number of attempts to shrink a failing sequence of transactions.

## `contractAddr`

Type | Default | Available in
-----|---------|-------------
Address | `"0x00a329c0648769a73afac7f9381e08fb43dbea72"` | *

Address to deploy the contract to test.

## `coverage`

Type | Default | Available in
-----|---------|-------------
Bool | `true`  | *

Enable the use of coverage-guided fuzzing and corpus collection.

## `corpusDir`

Type | Default | Available in
-----|---------|-------------
String | `null` | *

Directory to save the corpus collected (requires coverage enabled).

## `deployer`

Type | Default | Available in
-----|---------|-------------
Address | `"0x30000"` | *

Address of the deployer of the contract to test.

## `deployContracts`

Type | Default | Available in
-----|---------|-------------
[⁠[⁠Address, String⁠]⁠] | `[]` | *

Addresses and contract names to deploy using the available source code. The deployer address is the same as the contract to test. Echidna will error if the deployment fails.

## `deployBytecodes`

Type | Default | Available in
-----|---------|-------------
[⁠[⁠Address, String⁠]⁠] | `[]` | *

Addresses and bytecodes to deploy. The deployer address is the same as the contract to test. Echidna will error if the deployment fails.

## `sender`

Type | Default | Available in
-----|---------|-------------
[Address] | `["0x10000", "0x20000", "0x30000"]` | *

List of addresses to (randomly) use for the transactions sent during testing.

## `psender`

Type | Default | Available in
-----|---------|-------------
Address | `"0x10000"` | *

Address of the sender of the property to test.

## `prefix`

Type | Default | Available in
-----|---------|-------------
String | `"echidna_"` | *

Prefix of the function names used as properties in the contract to test.

## `propMaxGas`

Type | Default | Available in
-----|---------|-------------
Int  | `12500000` (current max gas per block) | *

Maximum amount of gas to consume when running function properties.

## `testMaxGas`

Type | Default | Available in
-----|---------|-------------
Int  | `12500000` (current max gas per block) | *

Maximum amount of gas to consume when running random transactions.

## `maxGasprice`

Type | Default | Available in
-----|---------|-------------
Int  | `0`     | *

Maximum amount of gas price to randomly use in transactions. Do not change it unless you absolutely need it.

## `maxTimeDelay`

Type | Default | Available in
-----|---------|-------------
Int  | `604800`  (one week) | *

Maximum amount of seconds of delay between transactions.

## `maxBlockDelay`

Type | Default | Available in
-----|---------|-------------
Int  | `60480` | *

Maximum amount of block numbers between transactions.

## `solcArgs`

Type | Default | Available in
-----|---------|-------------
String | `""` | *

Additional arguments to use in `solc` for compiling the contract to test.

## `cryticArgs`

Type | Default | Available in
-----|---------|-------------
[String] | `[]` | *

Additional arguments to use in `crytic-compile` for compiling the contract to test.

## `quiet`

Type | Default | Available in
-----|---------|-------------
Bool | `false` | *

Hide `solc` stderr output and additional information during the testing.

## `format`

Type | Default | Available in
-----|---------|-------------
String | `null` | *

Select a textual output format. By default, interactive TUI is run or text if a terminal is absent.

* `"text"`: simple textual interface.
* `"json"`: JSON output.
* `"none"`: no output.

## `balanceContract`

Type | Default | Available in
-----|---------|-------------
Int  | `0`     | *

Initial Ether balance of `contractAddr`.

## `balanceAddr`

Type | Default | Available in
-----|---------|-------------
Int  | `0xffffffff` | *

Initial Ether balance of `deployer` and each of the `sender` accounts.

## `maxValue`

Type | Default | Available in
-----|---------|-------------
Int | `100000000000000000000` (100 ETH) | *

Max amount of value in each randomly generated transaction.

## `testDestruction`

Type | Default | Available in
-----|---------|-------------
Bool | `false` | *

Add a special test that fails if a contract is self-destructed.

## `stopOnFail`

Type | Default | Available in
-----|---------|-------------
Bool | `false` | *

Stops the fuzzing campaign when the first test fails.

## `allContracts`

Type | Default | Available in
-----|---------|-------------
Bool | `false` | *

Makes Echidna fuzz the provided test contracts and any other deployed contract whose ABI is known at runtime.

## `allowFFI`

Type | Default | Available in
-----|---------|-------------
Bool | `false` | 2.1.0+

Allows the use of the HEVM `ffi` cheatcode.