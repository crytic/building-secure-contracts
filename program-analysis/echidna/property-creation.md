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
  address token;
  function getShares(address user) external returns (uint256)
  function createShares(uint256 val) external returns (uint256)
  function withdrawShares(uint256 val) external
  function transferShares(adresss to) external
  ...
```

In this example, users can deposit tokens from `token` to mint shares using `createShares`. They can withdraw shares using `withdrawShares` or transfer them 
to another using `transferShares`. Finally `getShares` will return the number of shares for every account. We will start with very basic properties:

```solidity
contract Test {
  DeFi c;
  constructor() {
    c = DeFi(..);
  }
  
  function getShares_never_reverts(uint val) public {
      bool b, _ = c.call.depositShares(val);
      assert(b);
  }

  function depositShares_never_reverts(uint val) public {
    if (token.balanceOf(msg.sender) <= val) {
        bool b, _ = c.call.depositShares(val);
        assert(b);
    }
  }
  
}
```

After you have your first round of properties, run Echidna to make sure they work as expected.


## Summary: TODO

TODO
