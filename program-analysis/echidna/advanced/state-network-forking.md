# On-chain fuzzing with state forking

**Table of contents:**

- [On-chain fuzzing with state forking](#on-chain-fuzzing-with-state-forking)
  - [Example](#example)
  - [Corpus and RPC cache](#corpus-and-rpc-cache)
  - [Coverage and Etherscan integration](#coverage-and-etherscan-integration)

## Example

One of the most anticipated features of Echidna 2.1.0 is the state network forking. This means that Echidna can run starting with an existing blockchain state provided by an external RPC service (Infura, Alchemy, local node, etc). 
This enables users to speed up the fuzzing setup when using already deployed contracts. For instance:

```solidity
interface IHevm {
    function warp(uint256 newTimestamp) external;
    function roll(uint256 newNumber) external;
}

interface Compound {
  function mint() external payable;
  function balanceOf(address) external view returns (uint256);
}

contract TestCompoundEthMint {
  address constant HEVM_ADDRESS = 0x7109709ECfa91a80626fF3989D68f67F5b1DD12D;
  IHevm hevm = IHevm(HEVM_ADDRESS);
  Compound comp = Compound(0x4Ddc2D193948926D02f9B1fE9e1daa0718270ED5);

  constructor() {
    hevm.roll(16771449);  // sets the correct block number
    hevm.warp(1678131671); // sets the expected timestamp for the block number
  }
  
  function assertNoBalance() public payable {
    require(comp.balanceOf(address(this)) == 0);
    comp.mint{value: msg.value}();
    assert(comp.balanceOf(address(this)) == 0);
  }
}
```

This test will fail if the minting of cETH success and the balance of the contract increases. In order to use this feature, the user needs to specify the RPC endpoint for Echidna to use before running the fuzzing campaign. This requires using the following environment variables: 

```
export ECHIDNA_RPC_URL=http://.. ECHIDNA_RPC_BLOCK=16771449
```

And then Echidna can be executed as usual. When tool starts, it will start fetching bytecodes and slots as needed. 
You can press the key `f` key to see which contracts/slots are fetched.

```
$ echidna compound.sol --test-mode assertion --contract TestCompoundEthMint
...
assertNoBalance(): failed!💥  
  Call sequence, shrinking (885/5000):
    assertNoBalance() Value: 0xd0411a5
```

## Corpus and RPC cache

If a corpus directory is used (e.g. `--corpus-dir corpus`), Echidna will save the fetched information inside the `cache` directory. 
This will speed-up the retest of the corpus since the are no data to fetch from the RPC. It is very recommended to use this feature, in particular
if the testing is performed as part of the CI tests.

```
$ ls corpus/cache/
block_16771449_fetch_cache_contracts.json  block_16771449_fetch_cache_slots.json
```

## Coverage and Etherscan integration

At the end of the execution, if the source code mapping of any executed on-chain contract is available on Etherscan, it will be automatically fetched for the coverage report. Optionally, an Etherscan key can be provided using the `ETHERSCAN_API_KEY` environment variable.

```
Fetching Solidity source for contract at address 0x4Ddc2D193948926D02f9B1fE9e1daa0718270ED5... Retrying (5 left). Error: Max rate limit reached, please use API Key for higher rate limit
Retrying (4 left). Error: Max rate limit reached, please use API Key for higher rate limit
Retrying (3 left). Error: Max rate limit reached, please use API Key for higher rate limit
Success!
Fetching Solidity source map for contract at address 0x4Ddc2D193948926D02f9B1fE9e1daa0718270ED5... Error!
```

While the source code for the [cETH contract is available](https://etherscan.io/address/0x4ddc2d193948926d02f9b1fe9e1daa0718270ed5#code), their source maps are NOT. 
In order to generate the coverage report for fetched contract, **both** source code and source maping should be available. In such case, there will be a new
directory inside the corpus to show coverage for each contract that was fetched. All the cases, coverage is available for the user-provided contracts:

```
20 |     |
21 | *r  |   function assertNoBalance() public payable {
22 | *r  |     require(comp.balanceOf(address(this)) == 0);
23 | *r  |     comp.mint{value: msg.value}();
24 | *r  |     assert(comp.balanceOf(address(this)) == 0);
25 |     |   }
```

