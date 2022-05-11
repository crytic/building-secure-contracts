# End-to-End testing with Echidna (Part I)

When smart contracts require a complex initialization and the time to do it is short, we want to avoid manually recreating a deployment for a fuzzing campaign with Echidna. That's why we have a new approach for testing using Echidna based on the deployments and execution of tests directly from ganache.

## Requirements:

This approach needs a smart contract project, with the following constraints:

* It should use Solidity: Vyper is not supported, since Slither/Echidna is not very effective at running these (e.g. no AST is included). 
* It should have tests or at least, a complete deployment script. 
* It should work with Slither. If it fails, [please report the issue](https://github.com/crytic/slither).

For this tutorial, [we used the drizzle-box example](https://github.com/truffle-box/drizzle-box). 

## Getting started:

Before stating, make sure you have the latest releases from [Echidna](https://github.com/crytic/echidna/releases) and [Etheno](https://github.com/crytic/etheno/releases) installed.

Then, install the packages to compile the project:

```
$ git clone https://github.com/truffle-box/drizzle-box
$ cd drizzle-box
$ npm i truffle
```

If ganache and ganache-cli are not installed, add them manually. In our example, we will run: 

```
$ npm i ganache ganache-cli 
```

Other projects using yarn will require:

```
$ yarn add ganache ganache-cli
```

It is also important to select *one* test script from the available tests. Ideally, this test will deploy all (or most) contracts, including mock/test ones. For this example, we are going to take a look to the `SimpleStorage` contract:

```solidity
contract SimpleStorage {
    event StorageSet(string _message);

    uint256 public storedData;

    function set(uint256 x) public {
        storedData = x;

        emit StorageSet("Data stored successfully!");
    }
}
```

This small contract allows to set the `storedData` state variable. As expected, we have a unit test that deploys and tests this contract (`simplestorage.js`):

```js
const SimpleStorage = artifacts.require("SimpleStorage");

contract("SimpleStorage", accounts => {
  it("...should store the value 89.", async () => {
    const simpleStorageInstance = await SimpleStorage.deployed();

    // Set value of 89
    await simpleStorageInstance.set(89, { from: accounts[0] });

    // Get stored value
    const storedData = await simpleStorageInstance.storedData.call();

    assert.equal(storedData, 89, "The value 89 was not stored.");
  });
});
```

## Capturing transactions

Before starting to write interesting properties, it is necessary to to collect an Etheno trace to replay it inside Echidna:

First, start Etheno: 

```
$ etheno --ganache --ganache-args "--deterministic --gasLimit 10000000" -x init.json
```

If Etheno fails to produce any output, then it fails to execute `ganache`. Check if `ganache` can be executed correctly from your terminal.

Meanwhile, in another terminal, run *one* test or the deployment process. How to run it depends on how the project was developed. For instance, for truffle, use:

```
$ truffle test test/test.js
```

for buidler:

```
$ buidler test test/test.js --network localhost
```

In the Drizzle example, we will run:

```
$ truffle test test/simplestorage.js --network develop.
```

After Etheno finishes, gently kill it using ctrl+c (twice). It will save the `init.json` file. If your test fails for some reason or you want to run a different one, restart etheno and re-run the test.

## Writing and running a property:

Once we have a json file with saved transactions, we can verify that the `SimpleStorage` contract is deployed at `0x871DD7C2B4b25E1Aa18728e9D5f2Af4C4e431f5c`, so we can easily write a contract (`./contracts/crytic/E2E.sol`) with a simple a property to test it:

```solidity
import "../SimpleStorage.sol";

contract E2E {
        SimpleStorage st = SimpleStorage(0x871DD7C2B4b25E1Aa18728e9D5f2Af4C4e431f5c);
        function crytic_const_storage() public returns(bool) {
            return st.storedData() == 89;
        }
}
```

This simple property checks if the stored data remains constant. To run it you will need the following echidna config file (`echidna.yaml`):

```yaml
prefix: crytic_
initialize: init.json
multi-abi: true
cryticArgs: ['--truffle-build-directory', 'app/src/contracts/'] # needed by drizzle
```

Then, running Echidna shows the results immediately: 

```
$ echidna-test . --contract E2E --config echidna.yaml
...
crytic_const_storage: failed!💥  
  Call sequence:
    (0x871dd7c2b4b25e1aa18728e9d5f2af4c4e431f5c).set(0) from: 0x0000000000000000000000000000000000010000
```

For this last step, make sure you are using `.` as a target for `echidna-test`. If you use the path to the `E2E.sol` file instead, then Echidna will not be able get information from all the deployed contracts to call the `set(uint256)` function and the property will never fail.

In the next part of this tutorial, we will explore how to easily find where contracts are deployed with a specific tool based on Slither. This will be useful if the deployment process is complex and we need to test an specific contract.
