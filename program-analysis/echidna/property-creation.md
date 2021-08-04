# How to write good properties 

**Table of contents:**

- [Introduction](#introduction)
- [A first approach](#a-first-approach)
- [Summary: TODO](#summary-TODO)

## Introduction

In this short tutorial, we will detail some ideas to write interesting or useful properties using Echidna.

## A first approach

One of the simplest properties to write using Echidna are going to assert when some function should revert/return exactly.

Let's suppose we have a contract like this one: 

```solidity
interface DeFi {
  ERC20 token;
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

After you have your first round of properties, run Echidna to make sure they work as expected. Perhaps you think this properties are too low level
to be useful, in particular if the code has a good coverage in terms of unit tests, but you could be surpriced how often a unexpected reverts/returns uncovers
a complex and severe issue. Moreover, we will see how these properties can be improved to cover more complex post-conditions.

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

## Enhacing the postcondition checks

If the previous properties are passing, this means that the preconditions are good enough, however the post-conditions are not very precise. 
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

## Summary: TODO

TODO
