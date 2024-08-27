# How to Write Good Properties Step by Step

**Table of contents:**

- [How to Write Good Properties Step by Step](#how-to-write-good-properties-step-by-step)
  - [Introduction](#introduction)
  - [A First Approach](#a-first-approach)
  - [Enhancing Postcondition Checks](#enhancing-postcondition-checks)
  - [Combining Properties](#combining-properties)
  - [Final Considerations](#final-considerations)
  - [Summary: How to Write Good Properties](#summary-how-to-write-good-properties)

## Introduction

In this short tutorial, we will detail some ideas for writing interesting or useful properties using Echidna. At each step, we will iteratively improve our properties.

## A First Approach

One of the simplest properties to write using Echidna is to throw an assertion when some function is expected to revert or return.

Let's suppose we have a contract interface like the one below:

```solidity
interface DeFi {
    ERC20 t;

    function getShares(address user) external returns (uint256);

    function createShares(uint256 val) external returns (uint256);

    function depositShares(uint256 val) external;

    function withdrawShares(uint256 val) external;

    function transferShares(address to) external;
}
```

In this example, users can deposit tokens using `depositShares`, mint shares using `createShares`, withdraw shares using `withdrawShares`, transfer all shares to another user using `transferShares`, and get the number of shares for any account using `getShares`. We will start with very basic properties:

```solidity
contract Test {
    DeFi defi;
    ERC20 token;

    constructor() {
        defi = DeFi(...);
        token.mint(address(this), ...);
    }

    function getShares_never_reverts() public {
        (bool b,) = defi.call(abi.encodeWithSignature("getShares(address)", address(this)));
        assert(b);
    }

    function depositShares_never_reverts(uint256 val) public {
        if (token.balanceOf(address(this)) >= val) {
            (bool b,) = defi.call(abi.encodeWithSignature("depositShares(uint256)", val));
            assert(b);
        }
    }

    function withdrawShares_never_reverts(uint256 val) public {
        if (defi.getShares(address(this)) >= val) {
            (bool b,) = defi.call(abi.encodeWithSignature("withdrawShares(uint256)", val));
            assert(b);
        }
    }

    function depositShares_can_revert(uint256 val) public {
        if (token.balanceOf(address(this)) < val) {
            (bool b,) = defi.call(abi.encodeWithSignature("depositShares(uint256)", val));
            assert(!b);
        }
    }

    function withdrawShares_can_revert(uint256 val) public {
        if (defi.getShares(address(this)) < val) {
            (bool b,) = defi.call(abi.encodeWithSignature("withdrawShares(uint256)", val));
            assert(!b);
        }
    }
}

```

After you have written your first version of properties, run Echidna to make sure they work as expected. During this tutorial, we will improve them step by step. It is strongly recommended to run the fuzzer at each step to increase the probability of detecting any potential issues.

Perhaps you think these properties are too low level to be useful, particularly if the code has good coverage in terms of unit tests.
But you will be surprised how often an unexpected revert or return uncovers a complex and severe issue. Moreover, we will see how these properties can be improved to cover more complex post-conditions.

Before we continue, we will improve these properties using [try/catch](https://docs.soliditylang.org/en/v0.6.0/control-structures.html#try-catch). The use of a low-level call forces us to manually encode the data, which can be error-prone (an error will always cause calls to revert). Note, this will only work if the codebase is using solc 0.6.0 or later:

```solidity
function depositShares_never_reverts(uint256 val) public {
    if (token.balanceOf(address(this)) >= val) {
        try defi.depositShares(val) {
            /* not reverted */
        } catch {
            assert(false);
        }
    }
}

function depositShares_can_revert(uint256 val) public {
    if (token.balanceOf(address(this)) < val) {
        try defi.depositShares(val) {
            assert(false);
        } catch {
            /* reverted */
        }
    }
}
```

## Enhancing Postcondition Checks

If the previous properties are passing, this means that the pre-conditions are good enough, however the post-conditions are not very precise.
Avoiding reverts doesn't mean that the contract is in a valid state. Let's add some basic preconditions:

```solidity
function depositShares_never_reverts(uint256 val) public {
    if (token.balanceOf(address(this)) >= val) {
        try defi.depositShares(val) {
            /* not reverted */
        } catch {
            assert(false);
        }
        assert(defi.getShares(address(this)) > 0);
    }
}

function withdrawShares_never_reverts(uint256 val) public {
    if (defi.getShares(address(this)) >= val) {
        try defi.withdrawShares(val) {
            /* not reverted */
        } catch {
            assert(false);
        }
        assert(token.balanceOf(address(this)) > 0);
    }
}
```

Hmm, it looks like it is not that easy to specify the value of shares or tokens obtained after each deposit or withdrawal. At least we can say that we must receive something, right?

## Combining Properties

In this generic example, it is unclear if there is a way to calculate how many shares or tokens we should receive after executing the deposit or withdraw operations. Of course, if we have that information, we should use it. In any case, what we can do here is to combine these two properties into a single one to be able check more precisely its preconditions.

```solidity
function deposit_withdraw_shares_never_reverts(uint256 val) public {
    uint256 original_balance = token.balanceOf(address(this));
    if (original_balance >= val) {
        try defi.depositShares(val) {
            /* not reverted */
        } catch {
            assert(false);
        }
        uint256 shares = defi.getShares(address(this));
        assert(shares > 0);
        try defi.withdrawShares(shares) {
            /* not reverted */
        } catch {
            assert(false);
        }
        assert(token.balanceOf(address(this)) == original_balance);
    }
}
```

The resulting property checks that calls to deposit or withdraw shares will never revert and once they execute, the original number of tokens remains the same. Keep in mind that this property should consider fees and any tolerated loss of precision (e.g. when the computation requires a division).

## Final Considerations

Two important considerations for this example:

We want Echidna to spend most of the execution exploring the contract to test. So, in order to make the properties more efficient, we should avoid dead branches where there is nothing to do. That's why we can improve `depositShares_never_reverts` to use:

```solidity
function depositShares_never_reverts(uint256 val) public {
    if (token.balanceOf(address(this)) > 0) {
        val = val % (token.balanceOf(address(this)) + 1);
        try defi.depositShares(val) { /* not reverted */ }
        catch {
            assert(false);
        }
        assert(defi.getShares(address(this)) > 0);
    } else {
        ... // code to test depositing zero tokens
    }
}
```

Additionally, combining properties does not mean that we will have to remove simpler ones. For instance, if we want to write `withdraw_deposit_shares_never_reverts`, in which we reverse the order of operations (withdraw and then deposit, instead of deposit and then withdraw), we will have to make sure `defi.getShares(address(this))` can be positive. An easy way to do it is to keep `depositShares_never_reverts`, since this code allows Echidna to deposit tokens from `address(this)` (otherwise, this is impossible).

## Summary: How to Write Good Properties

It is usually a good idea to start writing simple properties first and then improving them to make them more precise and easier to read. At each step, you should run a short fuzzing campaign to make sure they work as expected and try to catch issues early during the development of your smart contracts.
