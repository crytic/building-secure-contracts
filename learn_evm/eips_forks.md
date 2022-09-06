The following list every EIP associated to an Ethereum fork.

| Fork  | EIP  | What it does  | Opcode | Gas | Notes
|---|---|---|---|---|---|
| [Homestead (606)](https://eips.ethereum.org/EIPS/eip-606) | [2](https://eips.ethereum.org/EIPS/eip-2)  | Homestead Hard-fork Changes  |  | X | |
| [Homestead (606)](https://eips.ethereum.org/EIPS/eip-606) | [7](https://eips.ethereum.org/EIPS/eip-7)  | Delegatecall | X |  | |
| [Homestead (606)](https://eips.ethereum.org/EIPS/eip-606) | [8](https://eips.ethereum.org/EIPS/eip-8)  | Networking layer: devp2p Forward Compatibility Requirements for Homestead |  | | |
| [DAO Fork (779)](https://eips.ethereum.org/EIPS/eip-779) | [779](https://eips.ethereum.org/EIPS/eip-779)  | DAO Fork | | |
| [Tangerine Whistle (608)](https://eips.ethereum.org/EIPS/eip-608) | [150](https://eips.ethereum.org/EIPS/eip-150)  | Gas cost changes for IO-heavy operations| | X | Define the *all but one 64th* rule |
| [Spurious Dragon (607)](https://eips.ethereum.org/EIPS/eip-607) | [155](https://eips.ethereum.org/EIPS/eip-155)  | Simple replay attack protection | | | |
| [Spurious Dragon (607)](https://eips.ethereum.org/EIPS/eip-607) | [160](https://eips.ethereum.org/EIPS/eip-160)  | EXP cost increase | | X |  | |
| [Spurious Dragon (607)](https://eips.ethereum.org/EIPS/eip-607) | [161](https://eips.ethereum.org/EIPS/eip-161)  | State trie clearing (invariant-preserving alternative) | | X |  |
| [Spurious Dragon (607)](https://eips.ethereum.org/EIPS/eip-607) | [170](https://eips.ethereum.org/EIPS/eip-170)  | Contract code size limit | | | Change the semantics of CREATE
| [Byzantium (609)](https://eips.ethereum.org/EIPS/eip-609) | [100](https://eips.ethereum.org/EIPS/eip-100)  | Change difficulty adjustment to target mean block time including uncles | | |
| [Byzantium (609)](https://eips.ethereum.org/EIPS/eip-609) | [140](https://eips.ethereum.org/EIPS/eip-140)  | REVERT instruction | X | |
| [Byzantium (609)](https://eips.ethereum.org/EIPS/eip-609) | [196](https://eips.ethereum.org/EIPS/eip-196)  | Precompiled contracts for addition and scalar multiplication on the elliptic curve alt_bn128 | | |
| [Byzantium (609)](https://eips.ethereum.org/EIPS/eip-609) | [197](https://eips.ethereum.org/EIPS/eip-197)  | Precompiled contracts for optimal ate pairing check on the elliptic curve alt_bn128 | | |
| [Byzantium (609)](https://eips.ethereum.org/EIPS/eip-609) | [198](https://eips.ethereum.org/EIPS/eip-198)  | Precompiled contract for bigint modular exponentiation | | |
| [Byzantium (609)](https://eips.ethereum.org/EIPS/eip-609) | [211](https://eips.ethereum.org/EIPS/eip-211)  | RETURNDATASIZE and RETURNDATACOPY | X | |
| [Byzantium (609)](https://eips.ethereum.org/EIPS/eip-609) | [214](https://eips.ethereum.org/EIPS/eip-214)  | STATICCALL | X | |
| [Byzantium (609)](https://eips.ethereum.org/EIPS/eip-609) | [649](https://eips.ethereum.org/EIPS/eip-649)  | Metropolis Difficulty Bomb Delay and Block Reward Reduction | | |
| [Byzantium (609)](https://eips.ethereum.org/EIPS/eip-609) | [658](https://eips.ethereum.org/EIPS/eip-658)  | Embedding transaction status code in receipts | | |
| [Constantinople (1013)](https://eips.ethereum.org/EIPS/eip-1013) | [145](https://eips.ethereum.org/EIPS/eip-145)  | Bitwise shifting instructions in EVM  | X | |
| [Constantinople (1013)](https://eips.ethereum.org/EIPS/eip-1013) | [1014](https://eips.ethereum.org/EIPS/eip-1014)  | Skinny CREATE2 | X | |
| [Constantinople (1013)](https://eips.ethereum.org/EIPS/eip-1234) | [1234](https://eips.ethereum.org/EIPS/eip-1234)  | Constantinople Difficulty Bomb Delay and Block Reward Adjustment | | |
| [Constantinople (1013)](https://eips.ethereum.org/EIPS/eip-1234) | [1283](https://eips.ethereum.org/EIPS/eip-1283)  | Net gas metering for SSTORE without dirty maps | | X | This EIP leads to reentrancies risks (see [EIP-1283 incident report](https://github.com/trailofbits/publications/blob/master/reviews/EIP-1283.pdf)) and was directly removed with [EIP-1716](https://eips.ethereum.org/EIPS/eip-1716)
| [Petersburg (1716)](https://eips.ethereum.org/EIPS/eip-1716) | [1716](https://eips.ethereum.org/EIPS/eip-1716)  | Remove EIP-1283 | | X | See [EIP-1283 incident report](https://github.com/trailofbits/publications/blob/master/reviews/EIP-1283.pdf)
| [Istanbul (1679)](https://eips.ethereum.org/EIPS/eip-1679) | [152](https://eips.ethereum.org/EIPS/eip-152)  |  Precompiled contract for the BLAKE2 F compression function | | |
| [Istanbul (1679)](https://eips.ethereum.org/EIPS/eip-1679) | [1108](https://eips.ethereum.org/EIPS/eip-1108)  | Reduce alt_bn128 precompile gas costs | | X |
| [Istanbul (1679)](https://eips.ethereum.org/EIPS/eip-1679) | [1344](https://eips.ethereum.org/EIPS/eip-1344)  | ChainID opcode | X | |
| [Istanbul (1679)](https://eips.ethereum.org/EIPS/eip-1679) | [1884](https://eips.ethereum.org/EIPS/eip-1884)  | Repricing for trie-size-dependent opcodes | X | X | The EIP changes the gas cost of multiple opcodes, and add SELFBALANCE
| [Istanbul (1679)](https://eips.ethereum.org/EIPS/eip-1679) | [2028](https://eips.ethereum.org/EIPS/eip-2028)  | Transaction data gas cost reduction | | X |
| [Istanbul (1679)](https://eips.ethereum.org/EIPS/eip-1679) | [2200](https://eips.ethereum.org/EIPS/eip-2200)  | Structured Definitions for Net Gas Metering | | X
| [Muir Glacier (2387)](https://eips.ethereum.org/EIPS/eip-2387) | [2384](https://eips.ethereum.org/EIPS/eip-2384)  | Istanbul/Berlin Difficulty Bomb Delay | |
| [Berlin (2070)](https://github.com/ethereum/execution-specs/blob/a01c4c76e12fe9f0debf93bda7f67f002d77f8b4/network-upgrades/mainnet-upgrades/berlin.md) | [2565](https://eips.ethereum.org/EIPS/eip-2565)  | ModExp Gas Cost | | X |
| [Berlin (2070)](https://github.com/ethereum/execution-specs/blob/a01c4c76e12fe9f0debf93bda7f67f002d77f8b4/network-upgrades/mainnet-upgrades/berlin.md) | [2929](https://eips.ethereum.org/EIPS/eip-2929)  | Gas cost increases for state access opcodes | | X |
| [Berlin (2718)](https://github.com/ethereum/execution-specs/blob/a01c4c76e12fe9f0debf93bda7f67f002d77f8b4/network-upgrades/mainnet-upgrades/berlin.md) | [2718](https://eips.ethereum.org/EIPS/eip-2718)  | Typed Transaction Envelope | | |
| [Berlin (2718)](https://github.com/ethereum/execution-specs/blob/a01c4c76e12fe9f0debf93bda7f67f002d77f8b4/network-upgrades/mainnet-upgrades/berlin.md) | [2930](https://eips.ethereum.org/EIPS/eip-2930)  | Typed Transaction Envelope | | |
| [London](https://github.com/ethereum/execution-specs/blob/a01c4c76e12fe9f0debf93bda7f67f002d77f8b4/network-upgrades/mainnet-upgrades/london.md) | [1559](https://eips.ethereum.org/EIPS/eip-1559)  | Fee market change for ETH 1.0 chain | | X | Significant modifications of Ethereum gas pricing
| [London](https://github.com/ethereum/execution-specs/blob/a01c4c76e12fe9f0debf93bda7f67f002d77f8b4/network-upgrades/mainnet-upgrades/london.md) | [3198](https://eips.ethereum.org/EIPS/eip-3198)  | BASEFEE | X | |
| [London](https://github.com/ethereum/execution-specs/blob/a01c4c76e12fe9f0debf93bda7f67f002d77f8b4/network-upgrades/mainnet-upgrades/london.md) | [3529](https://eips.ethereum.org/EIPS/eip-3529)  | Reduction in refunds | | X | Remove [gas tokens](https://gastoken.io/) benefits
| [London](https://github.com/ethereum/execution-specs/blob/a01c4c76e12fe9f0debf93bda7f67f002d77f8b4/network-upgrades/mainnet-upgrades/london.md) | [3554](https://eips.ethereum.org/EIPS/eip-3554)  | Difficulty Bomb Delay to December 1st 2021 | | |
| [Arrow Glacier](https://github.com/ethereum/execution-specs/blob/bfe84c9a9b24695f160b4686d3b4640786ee9bac/network-upgrades/mainnet-upgrades/arrow-glacier.md) | [4345](https://eips.ethereum.org/EIPS/eip-4345)  |  Difficulty Bomb Delay to June 2022 | | |
| [Gray Glacier](https://github.com/ethereum/execution-specs/blob/bfe84c9a9b24695f160b4686d3b4640786ee9bac/network-upgrades/mainnet-upgrades/gray-glacier.md) | [5133](https://eips.ethereum.org/EIPS/eip-5133)  |  Difficulty Bomb Delay to mid-September 2022 | | |

In this table:
- `Opcode`: the EIP adds or removes an opcode
- `Gas`: the EIP changes the gas rules
