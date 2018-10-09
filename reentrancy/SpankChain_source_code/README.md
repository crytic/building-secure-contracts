# Overview

There are two contracts in this directory:

- `SpankChain.sol`, which was not vulnerable
- `SpankChain_Payment.sol` which contained the [SpankChain hack](https://medium.com/spankchain/we-got-spanked-what-we-know-so-far-d5ed3a0f38fe) vulnerability

Both contracts are preserved here for posterity. The "tl;dr" of the vulnerability:

- The attacker called `createChannel` to setup a channel
- they then called `LCOpenTimeout` repeatedly
- Since `LCOpenTimeout` sends ETH *and then* removes the balance, an attacker can call it over and over to drain the account

The fix? Never update state before a `transfer`, a `send`, a `call`, and so on; always perform those actions as the last step of the process in any contract that interacts with the 
world
