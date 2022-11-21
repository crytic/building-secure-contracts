# Exercise 7

**Table of contents:**

- [Exercise 7](#exercise-7)
  - [Setup](#setup)
  - [Exercise](#exercise)
  - [Solution](#solution)

Join the team on Slack at: https://empireslacking.herokuapp.com/ #ethereum

## Setup

1. Follow the instructions on the [Damn Vulnerable DeFi CTF][ctf] page, namely:
    - clone the repo via `git clone https://github.com/tinchoabbate/damn-vulnerable-defi -b v2.0.0`, and
    - install the dependencies via `yarn install`.
2. To run Echidna on these contracts you must comment out the `dependencyCompiler` section in `hardhat.config.js`. Otherwise, the project will not compile with [`crytic-compile`](https://github.com/crytic/crytic-compile). See the example provided [here](./exercises/exercise7/example.hardhat.config.ts).
3. Analyze the `before` function in `test/side-entrance/side-entrance.challenge.js` to identify what initial setup needs to be done.
4. Create a contract to be used for the property testing by Echidna.

No skeleton will be provided for this exercise.

## Goals

- Setup the testing environment with the right contracts and necessary balances.
- Add a property to check whether the balance of the `SideEntranceLenderPool` contract has changed.
- Create a `config.yaml` with the necessary configuration option(s).
- Once Echidna finds the bug, fix the issue, and re-try your property with Echidna.

Hint: It might help to start with doing a manual flashloan to get familiar with the workings of the target contract.
## Solution

This solution can be found in [exercises/exercise7/solution.sol](./exercises/exercise7/solution.sol)

[ctf]: https://www.damnvulnerabledefi.xyz/

<details>
<summary>Solution Explained (spoilers ahead)</summary>

The goal of the side entrance challenge is to realize that the contract's accounting of its ETH balance is misconfigured. `balanceBefore` is used to track the balance of the contract before the flash loan BUT `address(this).balance` is used to track the balance of the contract after the flash loan. Thus, you can use the deposit function to repay your flash loan while still maintaining that the contract's total balance of ETH has not changed (i.e. `address(this).balance >= balanceBefore`). Since the ETH that was deposited is now owned by you, you can now also withdraw it and drain all the funds from the contract.

In order for Echidna to be able to interact with the `SideEntranceLenderPool`, it has to be deployed first. However, deploying and funding it from the contract to be used by Echidna won't work, as the funding transaction's `msg.sender` is the contract itself. This means that the owner of the funds is the Echidna contract and therefore it can remove the funds by calling `withdraw()`, without the need for the exploit. 

To prevent that issue, a simple factory contract has to be created to deploy the pool without setting the Echidna property testing contract as the owner of the funds. This factory has a public function that deploys a `SideEntranceLenderPool`, funds it with the given amount, and return its address. Now, since the Echidna testing contract is not the owner of the funds, it cannot call `withdraw()` to empty the pool.

Now that the challenge is set up as intended, we proceed to solve it by instructing Echidna to do a flashloan. Using the `setEnableWithdraw` and `setEnableDeposit` Echidna will search for function(s) to call inside the flashloan callback to try and break the `testPoolBalance` property.
  
At some point Echidna will identify that if (1) `deposit` is used to pay back the flash loan and (2) `withdraw` is called right after, the `testPoolBalance` property breaks.

Example Echidna output:
```
$ echidna-test . --contract EchidnaSideEntranceLenderPool --config config.yaml
...
testPoolBalance(): failed!💥  
  Call sequence:
    execute() Value: 0x103
    setEnableDeposit(true,256)
    flashLoan(1)
    setEnableWithdraw(true)
    setEnableDeposit(false,0)
    execute()
    testPoolBalance()
...
```
</details>


