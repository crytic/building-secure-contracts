# Echidna JSON output

Echidna can emit campaign results as JSON with the `json` output driver. This page documents the current JSON representation produced by Echidna, including campaign results, tests, transactions, coverage, and corpus/reproducer files.

> **Scope:** This documents the JSON format implemented by Echidna. It is intended for consumers that parse Echidna output programmatically. The format may evolve as Echidna evolves.

## Campaign output

A JSON campaign has the following top-level structure:

```text
Campaign = {
  "success": bool,
  "error": string | null,
  "tests": [Test],
  "seed": number,
  "coverage": Coverage
}
```

- `success`: whether campaign encoding reports success.
- `error`: an optional campaign-level error.
- `tests`: the tests included in the campaign.
- `seed`: the seed used by the campaign.
- `coverage`: coverage information keyed by contract code hash.

## Test objects

Each test is represented as:

```text
Test = {
  "contract": string,
  "name": string,
  "status": string,
  "error": string | null,
  "reason": TxResult | null,
  "events": [string],
  "type": string,
  "transactions": [Transaction] | null
}
```

### Test type

The `type` field is the serialized form of the internal test type. The current JSON driver emits:

- `property`
- `assertion`

### Test status

The `status` field can be:

- `fuzzing`
- `shrinking`
- `solved`
- `verified`
- `passed`
- `error`

### Failure information

For falsified tests, `reason` contains the transaction result associated with the failure. For other test states it is `null`.

The `events` field contains the events extracted from the VM state associated with the test. It is an array and can be empty.

The `contract` and `name` fields are not currently populated with the Solidity contract/test names: the JSON encoder currently emits an empty contract value and the placeholder name `"name"`. This is tracked by [Echidna issue #415](https://github.com/crytic/echidna/issues/415).

## Transaction objects

Transactions in a falsifying test are represented as:

```text
Transaction = {
  "contract": string,
  "function": string,
  "arguments": [JSON value] | null,
  "gas": string,
  "gasprice": string,
  "value": string
}
```

### Transaction arguments

The `arguments` array contains JSON values produced from Echidna's ABI values:

- integers, addresses, booleans, and function values retain their textual representation as JSON strings;
- `bytes` and `bytesN` values are encoded as `0x`-prefixed hexadecimal strings;
- Solidity `string` values are JSON strings when they contain valid UTF-8, and are encoded as `0x`-prefixed hexadecimal when they are not valid UTF-8;
- arrays and tuples are encoded recursively as JSON arrays.

The value is therefore structured JSON rather than a list of stringified ABI values.

### Large numeric values

`gas`, `gasprice`, and `value` are serialized as decimal strings. Consumers should treat them as arbitrary-precision integer values rather than relying on a JSON number type, especially for values expressed in wei.

For example, JavaScript consumers can use `BigInt` when appropriate:

```javascript
const value = BigInt(transaction.value);
const gasPrice = BigInt(transaction.gasprice);
```

## Coverage

The `coverage` object is keyed by a `0x`-prefixed hexadecimal code hash.

Each key maps to a list of coverage entries represented by:

```text
[opIx, depths, results]
```

These entries describe coverage information for the corresponding code hash. The exact representation of the coverage vectors follows Echidna's internal coverage encoding and may evolve.

## Corpus and reproducer transaction files

When `corpusDir` is configured, Echidna saves transaction sequences under:

- `coverage/`
- `reproducers-unshrunk/`
- `reproducers-optimizations/`

The files contain JSON arrays but use the `.txt` extension.

A transaction in these files is serialized as:

```text
Transaction = {
  "call": Call,
  "src": address,
  "dst": address,
  "gas": number,
  "gasprice": string,
  "value": string,
  "delay": [string, string]
}
```

The `call` value is one of the JSON representations generated for:

- `SolCall`
- `SolCreate`
- `SolCalldata`
- `NoCall`

The `delay` pair represents the time and block delays associated with the transaction.

### Legacy corpus keys

For backwards compatibility, Echidna also accepts the older underscore-prefixed corpus fields:

```text
_call
_src
_dst
_gas'
_gasprice'
_value
_delay
```

New corpus files use the non-underscore field names.

## Parsing recommendations

Consumers should:

1. treat `gas`, `gasprice`, and `value` as arbitrary-precision decimal integers;
2. parse `arguments` as JSON values rather than assuming every argument is a string;
3. handle `null` for optional fields such as `error`, `reason`, and `transactions`;
4. avoid relying on the current placeholder `contract` and `name` values;
5. tolerate additional fields when parsing if forward compatibility is important.

For implementation details, compare this documentation with the JSON encoder in [`Echidna.Output.JSON`](https://github.com/crytic/echidna/blob/master/lib/Echidna/Output/JSON.hs) and the transaction/corpus serialization in [`Echidna.Types.Tx`](https://github.com/crytic/echidna/blob/master/lib/Echidna/Types/Tx.hs) and [`Echidna.Output.Corpus`](https://github.com/crytic/echidna/blob/master/lib/Echidna/Output/Corpus.hs).
