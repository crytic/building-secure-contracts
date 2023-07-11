# On-chain fuzzing with state forking

**Table of contents:**

- [On-chain fuzzing with state forking](#on-chain-fuzzing-with-state-forking)
  - [Introduction](#introduction)
  - [Example](#example)
  - [Corpus and RPC cache](#corpus-and-rpc-cache)
  - [Coverage and Etherscan integration](#coverage-and-etherscan-integration)

## Introduction

Echidna recently added support for state network forking, starting from the 2.1.0 release. In a few words, our fuzzer can run a campaign starting with an existing blockchain state provided by an external RPC service (Infura, Alchemy, local node, etc). This enables users to speed up the fuzzing setup when using already deployed contracts.

## Example

In the following contract, an assertion will fail if the call to [Compound ETH](https://etherscan.io/token/0x4Ddc2D193948926D02f9B1fE9e1daa0718270ED5) `mint` function succeeds and the balance of the contract increases.

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
        hevm.roll(16771449); // sets the correct block number
        hevm.warp(1678131671); // sets the expected timestamp for the block number
    }

    function assertNoBalance() public payable {
        require(comp.balanceOf(address(this)) == 0);
        comp.mint{ value: msg.value }();
        assert(comp.balanceOf(address(this)) == 0);
    }
}
```

In order to use this feature, the user needs to specify the RPC endpoint for Echidna to use before running the fuzzing campaign. This requires using the `ECHIDNA_RPC_URL` and `ECHIDNA_RPC_BLOCK` environment variables:

```
$ ECHIDNA_RPC_URL=http://.. ECHIDNA_RPC_BLOCK=16771449 echidna compound.sol --test-mode assertion --contract TestCompoundEthMint
...
assertNoBalance(): failed!💥
  Call sequence, shrinking (885/5000):
    assertNoBalance() Value: 0xd0411a5
```

Echidna will query contract code or storage slots as needed from the provided RPC node. You can press the key `f` key to see which contracts/slots are fetched.

Please note that only the state specified in the `ECHIDNA_RPC_BLOCK` will be fetched. If Echidna increases the block number, it is all just simulated locally but its state is still loaded from the initially set RPC block.

## Corpus and RPC cache

If a corpus directory is used (e.g. `--corpus-dir corpus`), Echidna will save the fetched information inside the `cache` directory.
This will speed up subsequent runs, since the data does not need to be fetched from the RPC. It is recommended to use this feature, in particular if the testing is performed as part of the CI tests.

```
$ ls corpus/cache/
block_16771449_fetch_cache_contracts.json  block_16771449_fetch_cache_slots.json
```

## Coverage and Etherscan integration

When the fuzzing campaign is over, if the source code mapping of any executed on-chain contract is available on Etherscan, it will be fetched automatically for the coverage report. Optionally, an Etherscan key can be provided using the `ETHERSCAN_API_KEY` environment variable.

```
Fetching Solidity source for contract at address 0x4Ddc2D193948926D02f9B1fE9e1daa0718270ED5... Retrying (5 left). Error: Max rate limit reached, please use API Key for higher rate limit
Retrying (4 left). Error: Max rate limit reached, please use API Key for higher rate limit
Retrying (3 left). Error: Max rate limit reached, please use API Key for higher rate limit
Success!
Fetching Solidity source map for contract at address 0x4Ddc2D193948926D02f9B1fE9e1daa0718270ED5... Error!
```

While the source code for the [cETH contract is available](https://etherscan.io/address/0x4ddc2d193948926d02f9b1fe9e1daa0718270ed5#code), their source maps are NOT.
In order to generate the coverage report for a fetched contract, **both** source code and source mapping should be available. In that case, there will be a new directory inside the corpus directory to show coverage for each contract that was fetched. In any case, the coverage report will be always available for the user-provided contracts, such as this one:

```
20 |     |
21 | *r  |   function assertNoBalance() public payable {
22 | *r  |     require(comp.balanceOf(address(this)) == 0);
23 | *r  |     comp.mint{value: msg.value}();
24 | *r  |     assert(comp.balanceOf(address(this)) == 0);
25 |     |   }
```
