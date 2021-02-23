## Requirements:

This approach needs a smart contract project, with the following constraints:

* It should use Solidity: Vyper is not supported, since Slither/Echidna is not very effective running these (e.g. no AST is included). 
* It should have tests or at least, a complete deployment script. 
* It should work with slither. If it fails, [please report the issue](https://github.com/crytic/slither).

For this document, [we used the metacoin example](https://github.com/truffle-box/metacoin-box).

## Getting started:

Before doing anything, let's install the tools we need:

* Install echidna from [master branch]().
* Install etheno from [X branch]().
* Install slither from [dev-new-props branch]().

Then, install the packages to compile the project:

```
$ git clone https://github.com/truffle-box/metacoin-box
$ cd metacoin-box
$ npm i
```

If ganache and ganache-cli are not installed, add them manually. For instance, running: 

```
$ npm i ganache ganache-cli 
```

or:

```
$ yarn add ganache ganache-cli
```

It is also important to select *one* test script from the available tests. Ideally, this test will deploy all (or most) contracts, including mock/test ones. 
For instance, here we have part of a test script that deploys and uses the metacoin contracts (`metacoin.js`):

```js
const MetaCoin = artifacts.require("MetaCoin");

contract('MetaCoin', (accounts) => {
  it('should put 10000 MetaCoin in the first account', async () => {
    const metaCoinInstance = await MetaCoin.deployed();
    const balance = await metaCoinInstance.getBalance.call(accounts[0]);

    assert.equal(balance.valueOf(), 10000, "10000 wasn't in the first account");
  });
  it('should call a function that depends on a linked library', async () => {
    const metaCoinInstance = await MetaCoin.deployed();
    const metaCoinBalance = (await metaCoinInstance.getBalance.call(accounts[0])).toNumber();
    const metaCoinEthBalance = (await metaCoinInstance.getBalanceInEth.call(accounts[0])).toNumber();

    assert.equal(metaCoinEthBalance, 2 * metaCoinBalance, 'Library function returned unexpected function, linkage may be broken');
  });
  ...
```

**❗ Important detail**: when selecting a test, if it hardcodes some date (or uses the current time), Echidna (or Manticore) could have issues reproducing the transactions. For instance, if you have something like this:

```js
const now = Math.floor((new Date()).getTime() / 1000);
```

Then, it is necessary to change the `now` constant:

```js
const now = 1524785992; // This is the value used by echidna/manticore
```

Otherwise, Echidna will fail to replicate the contract deployment from the scripts.

## Capturing transactions

Before starting to write interesting properties, it is necessary to to collect an etheno trace to replay it inside Echidna:

First, start Etheno: 

```
$ etheno --ganache --ganache-args "--deterministic --gasLimit 10000000" -x init.json
```

In another terminal, run *one* test or the deployment process. How to run it depends on how the project was developed. For instance, for truffle, use:

```
$ truffle test test/test.js
```

for buidler:

```
$ buidler test test/test.js --network localhost
```

When using MetaCoin, we will need to modify the `truffle-config.json` file to look like this:
```js
module.exports = {
  networks: {
    development: {
      host: "127.0.0.1",
      port: 8545,
      network_id: "*"
   }
  }
};
```

In the MetaCoin repository, we will run:

```
$ truffle test test/metacoin.js`.
```

After etheno finishes, kill it using ctrl+c (twice). It will save the `init.json` file.

## Writing properties:

Once we have a json file with saved transactions, we can run `slither-prop` to generate a template of the properties to use. This tool is optional, but very recommended. It will also show useful information on each transaction, so we can know where and how each contract was deployed.

``` 
$ slither-prop  . --txs init.json
```

This tool shows a list of transactions with some labels for each deployed/called contract. For instance:

```
List of transactions:
DEPLOYED Migrations at 0x946135c05cfc5e7c6d0f8259e12c53aa26a4f63e
0x6e27e32c5daacc590efb7cd3ad6232b60333ef59 called setCompleted(uint256) in 0x946135c05cfc5e7c6d0f8259e12c53aa26a4f63e
DEPLOYED ConvertLib at 0x9f54ce775a110c27761b78e6a684b95f13717292
CREATE at 0x312883951fc1724ef95667f67768691fe5d99d8b
0x6e27e32c5daacc590efb7cd3ad6232b60333ef59 called setCompleted(uint256) in 0x946135c05cfc5e7c6d0f8259e12c53aa26a4f63e
0x6e27e32c5daacc590efb7cd3ad6232b60333ef59 called sendCoin(address,uint256) in 0x312883951fc1724ef95667f67768691fe5d99d8b
Found the following accounts: 0x6e27e32c5daacc590efb7cd3ad6232b60333ef59
Write contracts/crytic/interfaces.sol
Write contracts/crytic/PropertiesAUTO.sol
Write contracts/crytic/TestAUTO.sol
Write echidna_config.yaml
To run Echidna:
	 echidna-test . --contract TestAUTO --config echidna_config.yaml 
```

For instance, if we are going to add a property about MetaCoin, we should use 0x312883951fc1724ef95667f67768691fe5d99d8b in the PropertiesAUTO contract (it's the contract that the test uses when calling sendCoin). 

```solidity
contract PropertiesAUTO is CryticInterface{

        MetaCoin mc = MetaCoin(0x312883951Fc1724EF95667F67768691FE5D99d8B);
        function crytic_self_send() public returns(bool) {
                // property here
        }

}
```

All the properties should be written from an external perspective. If you cannot write a property because some variables are not public/external, that's probably an issue, since users will not be able to know exactly what is going on inside the contract. 

Additionally, `slither-prop` provides the list of addresses used during the deployment. It is important to pay attention to them, since these could be useful to add into the echidna. For instance:

```
0x6e27e32c5daacc590efb7cd3ad6232b60333ef59 called setCompleted(uint256) in 0x946135c05cfc5e7c6d0f8259e12c53aa26a4f63e
0x6e27e32c5daacc590efb7cd3ad6232b60333ef59 called sendCoin(address,uint256) in 0x312883951fc1724ef95667f67768691fe5d99d8b
Found the following accounts: 0x6e27e32c5daacc590efb7cd3ad6232b60333ef59
… 
```

The first line shows the addresses from accounts[0] as we saw them in the testing script. It is a good idea to include these addresses in the echidna config, to allow our tool to generate transactions from them:

```yaml
sender: ['0x6e27e32c5daacc590efb7cd3ad6232b60333ef59']
psender: '0x6e27e32c5daacc590efb7cd3ad6232b60333ef59'
```
