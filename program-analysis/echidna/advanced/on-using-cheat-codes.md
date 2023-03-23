# How and when to use cheat codes

**Table of contents:**

- [How and when to use cheat codes](#how-and-when-to-use-cheat-codes)
  - [Introduction](#introduction)
  - [Cheat codes available in Echidna](#cheat-codes-available-in-echidna)
  - [Advise on using cheat codes](#advise-on-using-cheat-codes)

## Introduction

When solidity smart contract testing is performed from Solidity itself, usually requires some "help" in order to tackle some EVM/Solidity limitations. 
Cheat code are special functions that allow to change the state of the EVM in ways that are not posible in production. These were introduced by Dapptools in
hevm and adopted (and expanded) in other projects such as Foundry.

## Cheat codes available in Echidna

Since Echidna uses [hevm](https://github.com/ethereum/hevm), all the supported list of cheat code is documented here: https://hevm.dev/controlling-the-unit-testing-environment.html#cheat-codes. 
If a new cheat code is added in the future, Echidna only needs to update the hevm version and everything should work out of the box.   

As an example, this is code "simulates" the use of another sender for the external call using "prank":

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
    c.f();
  }
}
```

A specific example on the use of `sign` cheat code is available [here in our documentation](hevm-cheats-to-test-permit.md).

## Advise on how and when using cheat codes

While we provide support for the use of cheat codes, these should be used responsabily. We offer the following advise on the use of cheat codes:

* It should be used only if Echidna will not perform the same action with a native feature. For instance, Echidna automatically increases the timestamp and block number. There are [some reports of the optimizer interfering with (re)computation of the block.number or timestamp](https://github.com/ethereum/solidity/issues/12963#issuecomment-1110162425), which could generate incorrect tests when using cheat codes.
Using the corresponding built-in Echidna features should never intefer with the optimization level or any other compiler feature (if this happens, then it is a bug).

* It can introduce false positives on the testing. For instance, using `prank` to simulate calls from account that is not EOA (e.g. a contract) can allow transactions that are not possible in the blockchain. 

* Using too much cheat codes:
    * can be confusing or error-prone. Certain cheat code like `prank` allow to change caller in the next external call: It can be difficult to follow, in particular if it is used in internal functions or modifiers.  
    * will create a dependency of your code with the particular tool or cheat code implementation: It can cause produce migrations to other tools or reusing the test code to be more difficult than expected. 
