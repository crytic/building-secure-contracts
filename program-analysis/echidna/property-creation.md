# How to write good properties step by step

**Table of contents:**

- [Introduction](#introduction)
- [A first approach](#a-first-approach)
- [Enhacing postcondition checks](#enhacing-postcondition-checks)
- [Combining properties](combining-properties)
- [Summary: How to write good properties](#summary-how-to-write-good-properties)

## Introduction

In this short tutorial, we will detail some ideas to write interesting or useful properties using Echidna, in an iteratively process where we improved them at each steap.

## A first approach

One of the simplest properties to write using Echidna are going to assert when some function should revert/return exactly.

Let's suppose we have a contract like this one: 

```solidity
interface DeFi {
  ERC20 t;
  function getShares(address user) external returns (uint256)
  function createShares(uint256 val) external returns (uint256)
  function withdrawShares(uint256 val) external
  function transferShares(address to) external
  ...
```

In this example, users can deposit tokens from `token` to mint shares using `createShares`. They can withdraw shares using `withdrawShares` or transfer all of them to another user another using `transferShares`. Finally `getShares` will return the number of shares for every account. We will start with very basic properties:

```solidity
contract Test {
  DeFi c;
  ERC20 t;

  constructor() {
    c = DeFi(..);
    t.mint(address(this), ...);
  }
  
  function getShares_never_reverts(uint256 val) public {
      (bool b,) = c.call(abi.encodeWithSignature("getShares(address)", address(this)));
      assert(b);
  }

  function depositShares_never_reverts(uint256 val) public {
    if (token.balanceOf(address(this)) >= val) {
        (bool b,) = c.call(abi.encodeWithSignature("depositShares(uint256)", val));
        assert(b);
    }
  }
  
  function withdrawShares_never_reverts(uint256 val) public {
    if (c.getShares(address(this)) >= val) {
        (bool b,) = c.call(abi.encodeWithSignature("withdrawShares(uint256)", val));
        assert(b);
    }
  }
  
  function depositShares_can_revert(uint256 val) public {
    if (token.balanceOf(address(this)) < val) {
        (bool b,) = c.call(abi.encodeWithSignature("depositShares(uint256)", val));
        assert(!b);
    }
  }
  
  function withdrawShares_can_revert(uint256 val) public {
    if (c.getShares(address(this)) < val) {
        (bool b,) = c.call(abi.encodeWithSignature("withdrawShares(uint256)", val));
        assert(!b);
    }
  }
  
}
```

After you have write your first version of properties, run Echidna to make sure they work as expected. During this tutorial, we will improve them step by step, it is strongly recommended to run the fuzzer at each step, to increase the probability of detecting any potential issue. 

Perhaps you think this properties are too low level to be useful, in particular if the code has a good coverage in terms of unit tests, 
but you will be surpriced how often an unexpected reverts/returns uncovers a complex and severe issue. Moreover, we will see how these properties can be improved to cover more complex post-conditions.

Before continue, we will improve these properties using [try/catch](https://docs.soliditylang.org/en/v0.6.0/control-structures.html#try-catch). The use of a low level call force us to manually encode the data, which can be error prone (an error will cause calls to always revert). However, this will only works if the codebase is using solc 0.6.0 or later:


```solidity
  ...
  function depositShares_never_reverts(uint256 val) public {
    if (token.balanceOf(address(this)) >= val) {
        try c.depositShares(val) { /* not reverted */ } catch { assert(false); }
    }
  }
  
  function depositShares_can_revert(uint256 val) public {
    if (token.balanceOf(address(this)) < val) {
        try c.depositShares(val) { assert(false); } catch { /* reverted */ }
    }
  }
  ...
  
}
```

## Enhacing postcondition checks

If the previous properties are passing, this means that the pre-conditions are good enough, however the post-conditions are not very precise. 
Avoid reverting doesn't mean that the contract is in a valid state. Let's add some basic preconditions:

```solidity
  ...
  function depositShares_never_reverts(uint256 val) public {
    if (token.balanceOf(address(this)) >= val) {
        try c.depositShares(val) { /* not reverted */ } catch { assert(false); }
        assert(c.getShares(address(this)) > 0);
    }
  }
  
  function withdrawShares_never_reverts(uint256 val) public {
    if (c.getShares(address(this)) >= val) {
        try c.withdrawShares(val) { /* not reverted */ } catch { assert(false); }
        assert(t.balanceOf(address(this)) > 0);
    }
  }
  ...
  
}
```

Uhm, it looks like it is not that easy to specifying the value of shares/tokens obtained after each deposit/withdrawal. At least we can say that we must receveive something, right?

## Combining properties

In this generic example, it is unclear if there is a way to calculate how many shares or tokens we should receive after executing the deposit/withdraw operations. Of course, if we have that information, we should use it. In any case, what we can do here is to combine these two properties in a single one to be able check more precisely it's preconditions. 

```solidity
  ...
  function deposit_withdraw_shares_never_reverts(uint256 val) public {
    uint256 original_balance = token.balanceOf(address(this)); 
    if (original_balance >= val) {
        try c.depositShares(val) { /* not reverted */ } catch { assert(false); }
        uint256 shares = c.getShares(address(this);
        assert(shares > 0);
        try c.withdrawShares(shares) { /* not reverted */ } catch { assert(false); }
        assert(t.balanceOf(address(this)) == original_balance);
    }
  }
  ...
  
}
```

The resulting property checks that calls to deposit/withdraw shares will never revert and once they executed, the number of obtained tokens will not change. Keep in mind that this property should consider fees and any tolerated loss of precision (e.g. when the computation requires a division).

## Final considerations

Two important considerations for this example:

We want echidna to spend most of the execution exploring the contract to test, so in order to make the properties more efficient, we should avoid dead branches where there is nothing to do. That's why we can improve `depositShares_never_reverts` to use:

```solidity
  function depositShares_never_reverts(uint256 val) public {
    if(token.balanceOf(address(this)) > 0) {
      val = val % token.balanceOf(address(this));
      try c.depositShares(val) { /* not reverted */ } catch { assert(false); }
      assert(c.getShares(address(this)) > 0);
    } else {
      ... // code to test depositing zero tokens
    }
  }
```

Additionally, combining properties does not mean that we will have to remove simpler ones. For instance, if we want to write `withdraw_deposit_shares_never_reverts`, in which we reverse the order of operations (withdraw and then deposit, instead of deposit and then withdraw), we will have to make sure `c.getShares(address(this))` can be positive. An easy way to do it is to keep `depositShares_never_reverts`, since this code allows Echidna to deposit shares into the `address(this)` (otherwise, this is impossible).

## Summary: How to write good properties

It is usually a good idea to start writting simple properties first and then improving them to make then more precise and easier to read. At each step you should run a short fuzzing campaign to make sure they work as expected and try to catch issues early during the development of your smart contracts. 
