# Frequently asked questions about Echidna

This list contains answers to frequent questions related with the usage of Echidna. If this looks too difficult to understand for you, you need to make sure you already reviewed [all the other Echidna documentation](./README.md).

## Echidna fails to start or compile my contract, what should I do?

Start testing if `crytic-compile` can compile your contracts. If you are using a compilation framework such as truffle or hardhat, use:

`crytic-compile .`

And check for any errors. If there is an unexpected error, please [report it in the crytic-compile issue tracker](https://github.com/crytic/crytic-compile/issues).

If `crytic-compile` works fine, test `slither` to see if there is any issues with the information that this tool extract for running Echidna. Again, if you are using a compilation framework, use:

`slither . --print echidna`

If that command works correctly, it should print a json file with some information from your contracts, otherwise, report any error [in the slither issue tracker](https://github.com/crytic/slither/issues).
If everything here works, but Echidna still fails, please open an issue in our issue tracker or ask in the #ethereum channel of the EmpireHacking slack.

## How long should I run Echidna?

Echidna uses fuzzing testing which runs for a fixed amount of transactions (or a global timeout).
Users should specify a suitable number of transactions or a timeout (in seconds), depending on the amount of resources available for a fuzzing campaign
and the complexity of the code. Determining the best amount of time to run a fuzzer is still an [open research question](https://blog.trailofbits.com/2021/03/23/a-year-in-the-life-of-a-compiler-fuzzing-campaign/), however, [monitoring the code coverage of your smart contracts](./advanced/collecting-a-corpus.md) can be a good way to determinate if the fuzzing campaign should be extended.

## Why has Echidna not implemented fuzzing of smart contract constructors with parameters?

Echidna is focused on security testing during audits. When we perform testing, we adjust the fuzzing campaign to test with a limited number of possible constructor parameters (normally, the ones that are going to be used for the real deployment). We are not focused on issues that depend on alternative deployments that should not happen. On top of that, redeploying contracts during the fuzzing campaign has a performance impact and the sequences of transactions that we collect in the corpus could be more difficult (or even impossible) to reuse and mutate in different contexts.

## How does Echidna know which sequence of transactions should be added into the corpus?

Echidna starts generating a sequence with a number of transactions to execute. It will execute them one by one, collecting coverage information for every transaction. If a transaction adds new coverage, then the complete sequence (up to that transaction), will be added into the corpus.

## How is coverage information used?

Coverage information is used to determine if a sequence of transactions has reached a new program state and added into the internal corpus.

## What is coverage information exactly?

Coverage is a combination of the following information:

- Echidna reached a certain program counter in a given contract.
- The execution ended, either with stop, revert or a variety of errors (e.g. assertion failed, out of gas, not enough ether balance, etc)
- The number of EVM frames when the execution ended (in other words, how deep ends the execution in terms of internal transactions)

## How is the corpus used?

The corpus is used as the primary source of transactions to replay and mutate during a fuzzing campaign. The probability of using a sequence of transactions to replay and mutate is directly proportional to the number of transactions needed to add it into the corpus. In other words, more rare sequences are replayed and mutated more often during a fuzzing campaign.

## When a new sequence of transactions is added into the corpus, does this mean that a new line of code is always reached?

Not always, it means we reached some program state given our coverage definition.

## Why not use coverage per individual transaction, instead of per sequence of transactions?

Coverage per isolated transaction will be possible, however, it is incomplete vision of the coverage since some code requires previous transaction to reach some specific lines.

## How to know which type of testing should be used? (boolean properties, assertions, etc)

Check the [tutorial on selecting the right test mode](./basic/testing-modes.md)

## Why does Echidna return “Property X failed with no transactions made” when running one or more tests?

Before starting a fuzzing campaign, Echidna tests the properties with no transactions at all to check if they fail. In that case, a property can be detected to fail in the initial state (after the contract is deployed). You should check that the property is correct to know why it fails without any transactions.

## How can I know how a property or assertion failed?

Echidna indicates the cause of a failed test in the UI. For instance, if a boolean property X fails because of a revert, Echidna will show “property X FAILED! with ErrorRevert”, otherwise, it should show “property X FAILED! with ErrorReturnFalse”. Assertion can only fail because with “ErrorUnrecognizedOpcode”, which is how Solidity implements assertions in EVM.

## How can I know exactly where and how property or assertion failed?

Events are an easy way to output values from the EVM. You can use them to get information in the code that has the failed property or assertion. Only the events of transaction triggering the failure will be shown (this will be improved in the near future). Also, events are collected and displayed, even if the transaction reverted (despite the Yellow Paper states that the event log should be cleaned).

Another way to see where an assertion failed is using the coverage information. This requires to enable the corpus collection (e.g. `--corpus-dir X`) and check the coverage.\*.txt file to see something like this:

```
*e  |   function test(int x, address y, address z) public {
*e  |     require(x > 0 || x <= 0);
*e  |     assert(z != address(0x0));
*   |     assert(y != z);
*   |     state = x;
    |   }
```

The `e` marker indicates that Echidna collected a trace that ends with an assertion failure. As we can see,
the path ends in the assert, so it should fail there.

## Why coverage information seems incorrect or incomplete?

Coverage mappings can be imprecesie, however, if it fails completely, it could be that you are using the [`viaIR` optimization option](https://docs.soliditylang.org/en/v0.8.14/ir-breaking-changes.html?highlight=viaIR#solidity-ir-based-codegen-changes), which seems to have some unexpected impact on the solc maps that we are still investigating. As a workaround, disable `viaIR`.

## Echidna crashes showing ` NonEmpty.fromList: empty list`

Echidna relies on the Solidity metadata to detect where each contract is deployed. Please do not disable it. If this is not the case, please [open an issue](https://github.com/crytic/echidna/issues) in our issue tracker.

## Echidna stopped working for some reason. How can I debug it?

Use `--format text` and open an issue with the error you see in your console or ask in the #ethereum channel at the EmpireHacking slack.

## I am not getting expected results from Echidna tests. What can I do?

Sometimes it is useful to create small properties or assertions to test that the tool executed them correctly. For instance, for property mode:

```solidity
    function echidna_test() public returns (bool) {
       return false;
    }
```

And for assertion mode:

```solidity
    function test_assert_false() public {
       assert(false);
    }
```

If these are not failing, please [open an issue](https://github.com/crytic/echidna/issues) so we can take a look.
