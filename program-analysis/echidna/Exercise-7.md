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
3. For this exercise we will be using Etheno to deploy the `SideEntranceLenderPool` contract. You can find more about Etheno [here](./end-to-end-testing.md).
4. Analyze the `before` function in `test/side-entrance/side-entrance.challenge.js` to identify what initial setup needs to be done.
5. Create a contract called `E2E` to be used for the end-to-end testing by Echidna.

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
  
We instruct Echidna to do a flashloan. Using the `setEnableWithdraw` and `setEnableDeposit` Echidna will search for function(s) to call inside the flashloan callback to try and break the `testPoolBalance` property.
  
At some point Echidna will identify that if (1) `deposit` is used to pay back the flash loan and (2) `withdraw` is called right after, the `testPoolBalance` property breaks.

To use Etheno, you can use an example deployment script like the one below via Hardhat:
```javascript
const hre = require("hardhat");
const ethers = hre.ethers;

async function main() {
  const ETHER_IN_POOL = ethers.utils.parseEther("1000");

  [deployer, attacker] = await ethers.getSigners();

  const SideEntranceLenderPoolFactory = await ethers.getContractFactory(
    "SideEntranceLenderPool",
    deployer
  );

  pool = await SideEntranceLenderPoolFactory.deploy();
  await pool.deployed();
  console.log(`pool address ${pool.address}`);

  await this.pool.deposit({ value: ETHER_IN_POOL });

}

main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });
```
Make sure to add a localhost network to be able to deploy to Etheno. Example for Hardhat:
```javascript
  networks: {
    localhost: {
      url: "http://127.0.0.1:8545",
    },
  }
```

To deploy to Etheno run the following command:
```shell
etheno --ganache --ganache-args="--miner.blockGasLimit 10000000" -x init.json
```
In another shell run the following hardhat command:
```shell
npx hardhat run scripts/deploy.js --network localhost
```
  
And then your shell command works fine.

Don't forget to copy the initialization JSON file (`init.json`) from Etheno to your fuzzing environment!
  
Example Echidna output:
```
$ echidna-test . --contract E2E --config config.yaml
...
testPoolBalance(): failed!💥
  Call sequence, shrinking (3003/5000):
    setEnableDeposit(true,208)
    flashLoan(1)
    withdraw()
    testPoolBalance()
...
```
</details>


