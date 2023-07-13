# How to Test Assertions with Echidna

**Table of contents:**

- [How to Test Assertions with Echidna](#how-to-test-assertions-with-echidna)
  - [Introduction](#introduction)
  - [Write an Assertion](#write-an-assertion)
  - [Run Echidna](#run-echidna)
  - [When and How to Use Assertions](#when-and-how-to-use-assertions)
  - [Summary: Assertion Checking](#summary-assertion-checking)

## Introduction

In this short tutorial, we will demonstrate how to use Echidna to check assertions in smart contracts.

## Write an Assertion

Let's assume we have a contract like this one:

```solidity
contract Incrementor {
    uint256 private counter = 2 ** 200;

    function inc(uint256 val) public returns (uint256) {
        uint256 tmp = counter;
        unchecked {
            counter += val;
        }
        // tmp <= counter
        return (counter - tmp);
    }
}
```

We want to ensure that `tmp` is less than or equal to `counter` after returning its difference. We could write an Echidna property, but we would need to store the `tmp` value somewhere. Instead, we can use an assertion like this one (_[assert.sol](https://github.com/crytic/building-secure-contracts/blob/master/program-analysis/echidna/example/assert.sol)_):

```solidity
contract Incrementor {
    uint256 private counter = 2 ** 200;

    function inc(uint256 val) public returns (uint256) {
        uint256 tmp = counter;
        unchecked {
            counter += val;
        }
        assert(tmp <= counter);
        return (counter - tmp);
    }
}
```

We can also use a special event called `AssertionFailed` with any number of parameters to inform Echidna about a failed assertion without using `assert`. This will work in any contract. For example:

```solidity
contract Incrementor {
    event AssertionFailed(uint256);

    uint256 private counter = 2 ** 200;

    function inc(uint256 val) public returns (uint256) {
        uint256 tmp = counter;
        unchecked {
            counter += val;
        }
        if (tmp > counter) {
            emit AssertionFailed(counter);
        }
        return (counter - tmp);
    }
}
```

## Run Echidna

To enable assertion failure testing in Echidna, you can use `--test-mode assertion` directly from the command line.

Alternatively, you can create an [Echidna configuration file](https://github.com/crytic/echidna/wiki/Config), `config.yaml`, with `testMode` set for assertion checking:

```yaml
testMode: assertion
```

When we run this contract with Echidna, we receive the expected results:

```
echidna assert.sol --test-mode assertion
Analyzing contract: assert.sol:Incrementor
assertion in inc: failed!💥
  Call sequence, shrinking (2596/5000):
    inc(21711016731996786641919559689128982722488122124807605757398297001483711807488)
    inc(7237005577332262213973186563042994240829374041602535252466099000494570602496)
    inc(86844066927987146567678238756515930889952488499230423029593188005934847229952)

Seed: 1806480648350826486
```

As you can see, Echidna reports an assertion failure in the `inc` function. It is possible to add multiple assertions per function; however, Echidna cannot determine which assertion failed.

## When and How to Use Assertions

Assertions can be used as alternatives to explicit properties if the conditions to check are directly related to the correct use of some operation `f`. Adding assertions after some code will enforce that the check happens immediately after it is executed:

```solidity
function f(bytes memory args) public {
    // some complex code
    // ...
    assert(condition);
    // ...
}
```

In contrast, using an explicit Boolean property will randomly execute transactions, and there is no easy way to enforce exactly when it will be checked. It is still possible to use this workaround:

```solidity
function echidna_assert_after_f() public returns (bool) {
    f(args);
    return (condition);
}
```

However, there are some issues:

- It does not compile if `f` is declared as `internal` or `external`
- It is unclear which arguments should be used to call `f`
- The property will fail if `f` reverts

Assertions can help overcome these potential issues. For instance, they can be easily detected when calling internal or public functions:

```solidity
function f(bytes memory args) public {
    // some complex code
    // ...
    g(otherArgs) // this contains an assert
    // ...
}
```

If `g` is external, then assertion failure can be **only detected in Solidity 0.8.x or later**.

```solidity
function f(bytes memory args) public {
    // some complex code
    // ...
    contract.g(otherArgs) // this contains an assert
    // ...
}
```

In general, we recommend following [John Regehr's advice](https://blog.regehr.org/archives/1091) on using assertions:

- Do not force any side effects during the assertion checking. For instance: `assert(ChangeStateAndReturn() == 1)`
- Do not assert obvious statements. For instance `assert(var >= 0)` where `var` is declared as `uint256`.

Finally, please **do not use** `require` instead of `assert`, since Echidna will not be able to detect it (but the contract will revert anyway).

## Summary: Assertion Checking

The following summarizes the run of Echidna on our example (remember to use 0.7.x or older):

```solidity
contract Incrementor {
    uint256 private counter = 2 ** 200;

    function inc(uint256 val) public returns (uint256) {
        uint256 tmp = counter;
        counter += val;
        assert(tmp <= counter);
        return (counter - tmp);
    }
}
```

```bash
echidna assert.sol --test-mode assertion
Analyzing contract: assert.sol:Incrementor
assertion in inc: failed!💥
  Call sequence, shrinking (2596/5000):
    inc(21711016731996786641919559689128982722488122124807605757398297001483711807488)
    inc(7237005577332262213973186563042994240829374041602535252466099000494570602496)
    inc(86844066927987146567678238756515930889952488499230423029593188005934847229952)

Seed: 1806480648350826486
```

Echidna discovered that the assertion in `inc` can fail if this function is called multiple times with large arguments.
