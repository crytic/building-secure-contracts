# Incorrect interface
A contract interface defines functions with a different type signature than the implementation, causing two different method id's to be created.
As a result, when the interfact is called, the fallback method will be executed.

## Attack Scenario

- The interface is incorrectly defined. `Alice.set(uint)` takes an `uint` in `Bob.sol` but `Alice.set(int)` a `int` in `Alice.sol`. The two interfaces will produce two differents method IDs. As a result, Bob will call the fallback function of Alice rather than of `set`.

## Mitigations

Verify that type signatures are identical between inferfaces and implementations.

## Example

We now walk through how to find this vulnerability in the [Alice](Alice.sol) and [Bob](Bob.sol) contracts in this repo.

First, get the bytecode and the abi of the contracts:
```̀bash 
$ solc --bin Alice.sol
6060604052341561000f57600080fd5b5b6101158061001f6000396000f300606060405236156051576000357c0100000000000000000000000000000000000000000000000000000000900463ffffffff1680633c6bb436146067578063a5d5e46514608d578063e5c19b2d1460ad575b3415605b57600080fd5b5b60016000819055505b005b3415607157600080fd5b607760cd565b6040518082815260200191505060405180910390f35b3415609757600080fd5b60ab600480803590602001909190505060d3565b005b341560b757600080fd5b60cb600480803590602001909190505060de565b005b60005481565b806000819055505b50565b806000819055505b505600a165627a7a723058207d0ad6d1ce356adf9fa0284c9f887bb4b912204886b731c37c2ae5d16aef19a20029
$ solc --abi Alice.sol
[{"constant":true,"inputs":[],"name":"val","outputs":[{"name":"","type":"int256"}],"payable":false,"type":"function"},{"constant":false,"inputs":[{"name":"new_val","type":"int256"}],"name":"set_fixed","outputs":[],"payable":false,"type":"function"},{"constant":false,"inputs":[{"name":"new_val","type":"int256"}],"name":"set","outputs":[],"payable":false,"type":"function"},{"payable":false,"type":"fallback"}]


$ solc --bin Bob.sol
6060604052341561000f57600080fd5b5b6101f58061001f6000396000f30060606040526000357c0100000000000000000000000000000000000000000000000000000000900463ffffffff1680632801617e1461004957806390b2290e14610082575b600080fd5b341561005457600080fd5b610080600480803573ffffffffffffffffffffffffffffffffffffffff169060200190919050506100bb565b005b341561008d57600080fd5b6100b9600480803573ffffffffffffffffffffffffffffffffffffffff16906020019091905050610142565b005b8073ffffffffffffffffffffffffffffffffffffffff166360fe47b1602a6040518263ffffffff167c010000000000000000000000000000000000000000000000000000000002815260040180828152602001915050600060405180830381600087803b151561012a57600080fd5b6102c65a03f1151561013b57600080fd5b5050505b50565b8073ffffffffffffffffffffffffffffffffffffffff1663a5d5e465602a6040518263ffffffff167c010000000000000000000000000000000000000000000000000000000002815260040180828152602001915050600060405180830381600087803b15156101b157600080fd5b6102c65a03f115156101c257600080fd5b5050505b505600a165627a7a72305820f8c9dcade78d92097c18627223a8583507e9331ef1e5de02640ffc2e731111320029
$ solc --abi Bob.sol
[{"constant":false,"inputs":[{"name":"c","type":"address"}],"name":"set","outputs":[],"payable":false,"type":"function"},{"constant":false,"inputs":[{"name":"c","type":"address"}],"name":"set_fixed","outputs":[],"payable":false,"type":"function"}]
```

The following commands were tested on a private blockchain

```javascript
$ get attach

// this unlock the account for a limited amount of time
// if you have an error:
// Error: authentication needed: password or unlock
// you can to call unlockAccount again
personal.unlockAccount(eth.accounts[0], "apasswordtochange")

var bytecodeAlice = '0x6060604052341561000f57600080fd5b5b6101158061001f6000396000f300606060405236156051576000357c0100000000000000000000000000000000000000000000000000000000900463ffffffff1680633c6bb436146067578063a5d5e46514608d578063e5c19b2d1460ad575b3415605b57600080fd5b5b60016000819055505b005b3415607157600080fd5b607760cd565b6040518082815260200191505060405180910390f35b3415609757600080fd5b60ab600480803590602001909190505060d3565b005b341560b757600080fd5b60cb600480803590602001909190505060de565b005b60005481565b806000819055505b50565b806000819055505b505600a165627a7a723058207d0ad6d1ce356adf9fa0284c9f887bb4b912204886b731c37c2ae5d16aef19a20029'
var abiAlice = [{"constant":true,"inputs":[],"name":"val","outputs":[{"name":"","type":"int256"}],"payable":false,"type":"function"},{"constant":false,"inputs":[{"name":"new_val","type":"int256"}],"name":"set_fixed","outputs":[],"payable":false,"type":"function"},{"constant":false,"inputs":[{"name":"new_val","type":"int256"}],"name":"set","outputs":[],"payable":false,"type":"function"},{"payable":false,"type":"fallback"}]

var bytecodeBob = '0x6060604052341561000f57600080fd5b5b6101f58061001f6000396000f30060606040526000357c0100000000000000000000000000000000000000000000000000000000900463ffffffff1680632801617e1461004957806390b2290e14610082575b600080fd5b341561005457600080fd5b610080600480803573ffffffffffffffffffffffffffffffffffffffff169060200190919050506100bb565b005b341561008d57600080fd5b6100b9600480803573ffffffffffffffffffffffffffffffffffffffff16906020019091905050610142565b005b8073ffffffffffffffffffffffffffffffffffffffff166360fe47b1602a6040518263ffffffff167c010000000000000000000000000000000000000000000000000000000002815260040180828152602001915050600060405180830381600087803b151561012a57600080fd5b6102c65a03f1151561013b57600080fd5b5050505b50565b8073ffffffffffffffffffffffffffffffffffffffff1663a5d5e465602a6040518263ffffffff167c010000000000000000000000000000000000000000000000000000000002815260040180828152602001915050600060405180830381600087803b15156101b157600080fd5b6102c65a03f115156101c257600080fd5b5050505b505600a165627a7a72305820f8c9dcade78d92097c18627223a8583507e9331ef1e5de02640ffc2e731111320029'
var abiBob = [{"constant":false,"inputs":[{"name":"c","type":"address"}],"name":"set","outputs":[],"payable":false,"type":"function"},{"constant":false,"inputs":[{"name":"c","type":"address"}],"name":"set_fixed","outputs":[],"payable":false,"type":"function"}]

var contractAlice = eth.contract(abiAlice); 
var txDeployAlice = {from:eth.coinbase, data: bytecodeAlice, gas: 1000000}; 
var contractPartialInstanceAlice = contractAlice.new(txDeployAlice); 

// Wait to mine the block containing the transaction

var alice = contractAlice.at(contractPartialInstanceAlice.address);

var contractBob = eth.contract(abiBob); 
var txDeployBob = {from:eth.coinbase, data: bytecodeBob, gas: 1000000}; 
var contractPartialInstanceBob = contractBob.new(txDeployBob); 

// Wait to mine the block containing the transaction

var bob = contractBob.at(contractPartialInstanceBob.address);

// From now, wait for each transaction to be mined before calling
// the others transactions

// print the default value of val: 0
alice.val() 

// call bob.set, as the interface is wrong, it will call
// the fallback function of alice
bob.set(alice.address, {from: eth.accounts[0]} )
// print val: 1
alice.val()

// call the fixed version of the interface
bob.set_fixed(alice.address, {from: eth.accounts[0]} )
// print val: 42
alice.val()
```


