# On-chain fuzzing with state forking

**Table of contents:**

- [On-chain fuzzing with state forking](#on-chain-fuzzing-with-state-forking)
  - [Introduction](#introduction)
  - [Example](#example)
  - [Corpus and RPC cache](#corpus-and-rpc-cache)
  - [Coverage and source code fetching](#coverage-and-source-code-fetching)

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

## Coverage and source code fetching

When the fuzzing campaign is over, Echidna attempts to fetch source code for any
executed on-chain contracts to generate coverage reports. Starting with version
2.3.1, Echidna will first try [Sourcify](https://sourcify.dev/), and if that
fails, fall back to Etherscan.

[Sourcify](https://sourcify.dev/) is an open-source source code verification
service for Solidity and Vyper contracts. It doesn't require an API key and
its verified contracts are publicly available for download. Etherscan requires
an API key (via the `ETHERSCAN_API_KEY` environment variable or
`etherscanApiKey` config option).

Example output when Sourcify has the contract:

```
Fetching source for 0x4Ddc2D193948926D02f9B1fE9e1daa0718270ED5 from Sourcify... Success!
```

If Sourcify fails and Etherscan API key is configured:

```
Fetching source for 0x4Ddc2D193948926D02f9B1fE9e1daa0718270ED5 from Sourcify... Failed!
Fetching source for 0x4Ddc2D193948926D02f9B1fE9e1daa0718270ED5 from Etherscan... Success!
```

If Sourcify fails and no Etherscan API key was provided:

```
Fetching source for 0x4Ddc2D193948926D02f9B1fE9e1daa0718270ED5 from Sourcify... Failed!
Skipping Etherscan (no API key configured)
```

To disable on-chain source fetching entirely, use `--disable-onchain-sources` or
set `disableOnchainSources: true` in your config file.

In order to generate the coverage report for a fetched contract, **both** source
code and source mapping should be available. When using Etherscan, some
contracts may have source code available but lack source maps, such as for the
[cETH contract](https://etherscan.io/address/0x4ddc2d193948926d02f9b1fe9e1daa0718270ed5#code).
When both are available, there will be a new directory inside the corpus
directory to show coverage for each contract that was fetched.

In addition to that, the coverage report will always be available for the
user-provided contracts, such as this one:

```
20 |     |
21 | *r  |   function assertNoBalance() public payable {
22 | *r  |     require(comp.balanceOf(address(this)) == 0);
23 | *r  |     comp.mint{value: msg.value}();
24 | *r  |     assert(comp.balanceOf(address(this)) == 0);
25 |     |   }
```
