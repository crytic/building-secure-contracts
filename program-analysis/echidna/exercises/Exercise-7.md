# Exercise 7

**Table of contents:**

- [Exercise 7](#exercise-7)
  - [Setup](#setup)
  - [Goals](#goals)
  - [Solution](#solution)

Join the team on Slack at: https://slack.empirehacking.nyc/ #ethereum

## Setup

1. Clone the repository: `git clone https://github.com/crytic/damn-vulnerable-defi-echidna`
2. Install dependencies using `yarn install`.
3. Analyze the `before` function in `test/side-entrance/side-entrance.challenge.js` to determine the initial setup requirements.
4. Create a contract to be used for property testing with Echidna.

No skeleton will be provided for this exercise.

## Goals

- Set up the testing environment with appropriate contracts and necessary balances.
- Add a property to check if the balance of the `SideEntranceLenderPool` contract has changed.
- Create a `config.yaml` with the required configuration option(s).
- After Echidna discovers the bug, fix the issue and test your property with Echidna again.

Hint: To become familiar with the workings of the target contract, try manually executing a flash loan.

## Solution

The solution can be found in [solution.sol](https://github.com/crytic/building-secure-contracts/tree/master/program-analysis/echidna/exercises/exercise7/solution.sol).

[ctf]: https://www.damnvulnerabledefi.xyz/

<details>
<summary>Solution Explained (spoilers ahead)</summary>

The goal of the side entrance challenge is to realize that the contract's ETH balance accounting is misconfigured. The `balanceBefore` variable tracks the contract's balance before the flash loan, while `address(this).balance` tracks the balance after the flash loan. As a result, you can use the deposit function to repay your flash loan while maintaining the notion that the contract's total ETH balance hasn't changed (i.e., `address(this).balance >= balanceBefore`). However, since you now own the deposited ETH, you can also withdraw it and drain all the funds from the contract.

For Echidna to interact with the `SideEntranceLenderPool`, it must be deployed first. Deploying and funding the pool from the Echidna property testing contract won't work, as the funding transaction's `msg.sender` will be the contract itself. This means that the Echidna contract will own the funds, allowing it to remove them by calling `withdraw()` without exploiting the vulnerability.

To avoid the above issue, create a simple factory contract that deploys the pool without setting the Echidna property testing contract as the owner of the funds. This factory will have a public function that deploys a `SideEntranceLenderPool`, funds it with the given amount, and returns its address. Since the Echidna testing contract does not own the funds, it cannot call `withdraw()` to empty the pool.

With the challenge properly set up, instruct Echidna to execute a flash loan. By using the `setEnableWithdraw` and `setEnableDeposit`, Echidna will search for functions to call within the flash loan callback to attempt to break the `testPoolBalance` property.

Echidna will eventually discover that if (1) `deposit` is used to repay the flash loan and (2) `withdraw` is called immediately afterward, the `testPoolBalance` property fails.

Example Echidna output:

```
echidna . --contract EchidnaSideEntranceLenderPool --config config.yaml
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
