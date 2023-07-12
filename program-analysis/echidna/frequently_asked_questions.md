# Frequently Asked Questions about Echidna

This list provides answers to frequently asked questions related to the usage of Echidna. If you find this information challenging to understand, please ensure you have already reviewed [all the other Echidna documentation](./README.md).

## Echidna fails to start or compile my contract; what should I do?

Begin by testing if `crytic-compile` can compile your contracts. If you are using a compilation framework such as Truffle or Hardhat, use the command:

`crytic-compile .`

and check for any errors. If there is an unexpected error, please [report it in the crytic-compile issue tracker](https://github.com/crytic/crytic-compile/issues).

If `crytic-compile` works fine, test `slither` to see if there are any issues with the information it extracts for running Echidna. Again, if you are using a compilation framework, use the command:

`slither . --print echidna`

If that command executes correctly, it should print a JSON file containing some information from your contracts; otherwise, report any errors [in the slither issue tracker](https://github.com/crytic/slither/issues).
If everything here works, but Echidna still fails, please open an issue in our issue tracker or ask in the #ethereum channel of the EmpireHacking Slack.

## How long should I run Echidna?

Echidna uses fuzzing testing, which runs for a fixed number of transactions (or a global timeout).
Users should specify an appropriate number of transactions or a timeout (in seconds) depending on the available resources for a fuzzing campaign
and the complexity of the code. Determining the best amount of time to run a fuzzer is still an [open research question](https://blog.trailofbits.com/2021/03/23/a-year-in-the-life-of-a-compiler-fuzzing-campaign/); however, [monitoring the code coverage of your smart contracts](./advanced/collecting-a-corpus.md) can be a good way to determine if the fuzzing campaign should be extended.

## Why has Echidna not implemented fuzzing of smart contract constructors with parameters?

Echidna is focused on security testing during audits. When we perform testing, we tailor the fuzzing campaign to test a limited number of possible constructor parameters (normally, the ones that will be used for the actual deployment). We do not focus on issues that depend on alternative deployments that should not occur. Moreover, redeploying contracts during the fuzzing campaign has a performance impact, and the sequences of transactions that we collect in the corpus may be more challenging (or even impossible) to reuse and mutate in different contexts.

## How does Echidna determine which sequence of transactions should be added to the corpus?

Echidna begins by generating a sequence with a number of transactions to execute. It executes each transaction one by one, collecting coverage information for every transaction. If a transaction adds new coverage, then the entire sequence (up to that transaction) is added to the corpus.

## How is coverage information used?

Coverage information is used to determine if a sequence of transactions has reached a new program state and is added to the internal corpus.

## What exactly is coverage information?

Coverage is a combination of the following information:

- Echidna reached a specific program counter in a given contract.
- The execution ended, either with stop, revert, or a variety of errors (e.g., assertion failed, out of gas, insufficient ether balance, etc.)
- The number of EVM frames when the execution ended (in other words, how deep the execution ends in terms of internal transactions)

## How is the corpus used?

The corpus is used as the primary source of transactions to replay and mutate during a fuzzing campaign. The probability of using a sequence of transactions to replay and mutate is directly proportional to the number of transactions needed to add it to the corpus. In other words, rarer sequences are replayed and mutated more frequently during a fuzzing campaign.

## When a new sequence of transactions is added to the corpus, does this always mean that a new line of code is reached?

Not always. It means we have reached a certain program state given our coverage definition.

## Why not use coverage per individual transaction instead of per sequence of transactions?

Coverage per individual transaction is possible, but it provides an incomplete view of the coverage since some code requires previous transactions to reach specific lines.

## How do I know which type of testing should be used (boolean properties, assertions, etc.)?

Refer to the [tutorial on selecting the right test mode](./basic/testing-modes.md).

## Why does Echidna return "Property X failed with no transactions made" when running one or more tests?

Before starting a fuzzing campaign, Echidna tests the properties without any transactions to check for failures. In that case, a property may fail in the initial state (after the contract is deployed). You should check that the property is correct to understand why it fails without any transactions.

## How can I determine how a property or assertion failed?

Echidna indicates the cause of a failed test in the UI. For instance, if a boolean property X fails due to a revert, Echidna will display "Property X FAILED! with ErrorRevert"; otherwise, it should show "Property X FAILED! with ErrorReturnFalse". An assertion can only fail with "ErrorUnrecognizedOpcode," which is how Solidity implements assertions in the EVM.

## How can I pinpoint where and how a property or assertion failed?

Events are an easy way to output values from the EVM. You can use them to obtain information in the code containing the failed property or assertion. Only the events of the transaction triggering the failure will be shown (this will be improved in the near future). Also, events are collected and displayed, even if the transaction reverted (despite the Yellow Paper stating that the event log should be cleared).

Another way to see where an assertion failed is by using the coverage information. This requires enabling corpus collection (e.g., `--corpus-dir X`) and checking the coverage in the coverage\*.txt file, such as:

```
*e  |   function test(int x, address y, address z) public {
*e  |     require(x > 0 || x <= 0);
*e  |     assert(z != address(0x0));
*   |     assert(y != z);
*   |     state = x;
    |   }
```

The `e` marker indicates that Echidna collected a trace that ended with an assertion failure. As we can see,
the path ends at the assert statement, so it should fail there.

## Why does coverage information seem incorrect or incomplete?

Coverage mappings can be imprecise; however, if they fail completely, it could be that you are using the [`viaIR` optimization option](https://docs.soliditylang.org/en/v0.8.14/ir-breaking-changes.html?highlight=viaIR#solidity-ir-based-codegen-changes), which appears to have some unexpected impact on the solc maps that we are still investigating. As a workaround, disable `viaIR`.

## Echidna crashes, displaying "NonEmpty.fromList: empty list"

Echidna relies on the Solidity metadata to detect where each contract is deployed. Please do not disable it. If this is not the case, please [open an issue](https://github.com/crytic/echidna/issues) in our issue tracker.

## Echidna stopped working for some reason. How can I debug it?

Use `--format text` and open an issue with the error you see in your console, or ask in the #ethereum channel at the EmpireHacking Slack.

## I am not getting the expected results from Echidna tests. What can I do?

Sometimes, it is useful to create small properties or assertions to test whether the tool executed them correctly. For instance, for property mode:

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

If these do not fail, please [open an issue](https://github.com/crytic/echidna/issues) so that we can investigate.
