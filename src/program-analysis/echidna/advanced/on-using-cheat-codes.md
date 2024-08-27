# How and when to use cheat codes

**Table of contents:**

- [How and when to use cheat codes](#how-and-when-to-use-cheat-codes)
  - [Introduction](#introduction)
  - [Cheat codes available in Echidna](#cheat-codes-available-in-echidna)
  - [Risks of cheat codes](#risks-of-cheat-codes)

## Introduction

When testing smart contracts in Solidity itself, it can be helpful to use cheat codes in order to overcome some of the limitations of the EVM/Solidity.
Cheat codes are special functions that allow to change the state of the EVM in ways that are not posible in production. These were introduced by Dapptools in hevm and adopted (and expanded) in other projects such as Foundry.

## Cheat codes available in Echidna

Echidna supports all cheat codes that are available in [hevm](https://github.com/ethereum/hevm). These are documented here: [https://hevm.dev/controlling-the-unit-testing-environment.html#cheat-codes](https://hevm.dev/ds-test-tutorial.html#supported-cheat-codes).
If a new cheat code is added in the future, Echidna only needs to update the hevm version and everything should work out of the box.

As an example, the `prank` cheat code is able to set the `msg.sender` address in the context of the next external call:

```solidity
interface IHevm {
    function prank(address) external;
}

contract TestPrank {
  address constant HEVM_ADDRESS = 0x7109709ECfa91a80626fF3989D68f67F5b1DD12D;
  IHevm hevm = IHevm(HEVM_ADDRESS);
  Contract c = ...

  function prankContract() public payable {
    hevm.prank(address(0x42424242);
    c.f(); // `c` will be called with `msg.sender = 0x42424242`
  }
}
```

A specific example on the use of `sign` cheat code is available [here in our documentation](hevm-cheats-to-test-permit.md).

## Risks of cheat codes

While we provide support for the use of cheat codes, these should be used responsibly. Consider that:

- Cheat codes can break certain assumptions in Solidity. For example, the compiler assumes that `block.number` is constant during a transaction. There are [reports of the optimizer interfering with (re)computation of the `block.number` or `block.timestamp`](https://github.com/ethereum/solidity/issues/12963#issuecomment-1110162425), which can generate incorrect tests when using cheat codes.

- Cheat codes can introduce false positives on the testing. For instance, using `prank` to simulate calls from a contract can allow transactions that are not possible in the blockchain.

- Using too many cheat codes:
  - can be confusing or error-prone. Certain cheat code like `prank` allow to change caller in the next external call: It can be difficult to follow, in particular if it is used in internal functions or modifiers.
  - will create a dependency of your code with the particular tool or cheat code implementation: It can cause produce migrations to other tools or reusing the test code to be more difficult than expected.
