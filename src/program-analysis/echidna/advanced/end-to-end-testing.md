# End-to-End Testing with Echidna (Part I)

When smart contracts require complex initialization and the time to do so is short, we want to avoid manually recreating a deployment for a fuzzing campaign with Echidna. That's why we have a new approach for testing using Echidna based on the deployments and execution of tests directly from Ganache.

## Requirements:

This approach needs a smart contract project with the following constraints:

- It should use Solidity; Vyper is not supported since Slither/Echidna is not very effective at running these (e.g. no AST is included).
- It should have tests or at least a complete deployment script.
- It should work with Slither. If it fails, [please report the issue](https://github.com/crytic/slither).

For this tutorial, [we used the Drizzle-box example](https://github.com/truffle-box/drizzle-box).

## Getting Started:

Before starting, make sure you have the latest releases from [Echidna](https://github.com/crytic/echidna/releases) and [Etheno](https://github.com/crytic/etheno/releases) installed.

Then, install the packages to compile the project:

```
git clone https://github.com/truffle-box/drizzle-box
cd drizzle-box
npm i truffle
```

If `ganache` is not installed, add it manually. In our example, we will run:

```
npm -g i ganache
```

Other projects using Yarn will require:

```
yarn global add ganache
```

Ensure that `$ ganache --version` outputs `ganache v7.3.2` or greater.

It is also important to select _one_ test script from the available tests. Ideally, this test will deploy all (or most) contracts, including mock/test ones. For this example, we are going to examine the `SimpleStorage` contract:

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

This small contract allows the `storedData` state variable to be set. As expected, we have a unit test that deploys and tests this contract (`simplestorage.js`):

```js
const SimpleStorage = artifacts.require("SimpleStorage");

contract("SimpleStorage", (accounts) => {
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

## Capturing Transactions

Before starting to write interesting properties, it is necessary to collect an Etheno trace to replay it inside Echidna:

First, start Etheno:

```bash
etheno --ganache --ganache-args="--miner.blockGasLimit 10000000" -x init.json
```

By default, the following Ganache arguments are set via Etheno:

- `-d`: Ganache will use a pre-defined, deterministic seed to create all accounts.
- `--chain.allowUnlimitedContractSize`: Allows unlimited contract sizes while debugging. This is set so that there is no size limitation on the contracts that are going to be deployed.
- `-p <port_num>`: The `port_num` will be set to (1) the value of `--ganache-port` or (2) Etheno will choose the smallest port number higher than the port number on which Etheno’s JSON RPC server is running.

**NOTE:** If you are using Docker to run Etheno, the commands should be:

```bash
docker run -it -p 8545:8545 -v ~/etheno:/home/etheno/ trailofbits/etheno
(you will now be working within the Docker instance)
etheno --ganache --ganache-args="--miner.blockGasLimit 10000000" -x init.json
```

- The `-p` in the _first command_ publishes (i.e., exposes) port 8545 from inside the Docker container out to port 8545 on the host.
- The `-v` in the _first command_ maps a directory from inside the Docker container to one outside the Docker container. After Etheno exits, the `init.json` file will now be in the `~/etheno` folder on the host.

Note that if the deployment fails to complete successfully due to a `ProviderError: exceeds block gas limit` exception, increasing the `--miner.blockGasLimit` value can help. This is especially helpful for large contract deployments. Learn more about the various Ganache command-line arguments that can be set by clicking [here](https://www.npmjs.com/package/ganache).

Additionally, if Etheno fails to produce any output, it may have failed to execute `ganache` under-the-hood. Check if `ganache` (with the associated command-line arguments) can be executed correctly from your terminal without the use of Etheno.

Meanwhile, in another terminal, run _one_ test or the deployment process. How to run it depends on how the project was developed. For instance, for Truffle, use:

```
truffle test test/test.js
```

For Buidler:

```
buidler test test/test.js --network localhost
```

In the Drizzle example, we will run:

```
truffle test test/simplestorage.js --network develop.
```

After Etheno finishes, gently kill it using Ctrl+C (or Command+C on Mac). It will save the `init.json` file. If your test fails for some reason, or you want to run a different one, restart Etheno and re-run the test.

## Writing and Running a Property

Once we have a JSON file with saved transactions, we can verify that the `SimpleStorage` contract is deployed at `0x871DD7C2B4b25E1Aa18728e9D5f2Af4C4e431f5c`. We can easily write a contract in `contracts/crytic/E2E.sol` with a simple property to test it:

```solidity
import "../SimpleStorage.sol";

contract E2E {
    SimpleStorage st = SimpleStorage(0x871DD7C2B4b25E1Aa18728e9D5f2Af4C4e431f5c);

    function crytic_const_storage() public returns (bool) {
        return st.storedData() == 89;
    }
}
```

For large, multi-contract deployments, using `console.log` to print out the deployed contract addresses can be valuable in quickly setting up the Echidna testing contract.

This simple property checks if the stored data remains constant. To run it, you will need the following Echidna config file (`echidna.yaml`):

```yaml
prefix: crytic_
initialize: init.json
allContracts: true
cryticArgs: ["--truffle-build-directory", "app/src/contracts/"] # needed by Drizzle
```

Then, running Echidna shows the results immediately:

```
echidna . --contract E2E --config echidna.yaml
...
crytic_const_storage: failed!💥
  Call sequence:
    (0x871dd7c2b4b25e1aa18728e9d5f2af4c4e431f5c).set(0) from: 0x0000000000000000000000000000000000010000
```

For this last step, make sure you are using `.` as a target for `echidna`. If you use the path to the `E2E.sol` file instead, Echidna will not be able to get information from all the deployed contracts to call the `set(uint256)` function, and the property will never fail.

## Key Considerations:

When using Etheno with Echidna, note that there are two edge cases that may cause unexpected behavior:

1. Function calls that use ether: The accounts created and used for testing in Ganache are not the same as the accounts used to send transactions in Echidna. Thus, the account balances of the Ganache accounts do not carry over to the accounts used by Echidna. If there is a function call logged by Etheno that requires the transfer of some ether from an account that exists in Ganache, this call will fail in Echidna.
2. Fuzz tests that rely on `block.timestamp`: The concept of time is different between Ganache and Echidna. Echidna always starts with a fixed timestamp, while Etheno will use Ganache's concept of time. This means that assertions or requirements in a fuzz test that rely on timestamp comparisons/evaluations may fail in Echidna.

In the next part of this tutorial, we will explore how to easily find where contracts are deployed with a specific tool based on Slither. This will be useful if the deployment process is complex, and we need to test a particular contract.
