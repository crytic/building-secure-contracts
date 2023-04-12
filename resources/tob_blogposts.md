# Trail of Bits Blog Posts

The following contains blockchain-related blog posts made by Trail of Bits.

- [Trail of Bits Blog Posts](#trail-of-bits-blog-posts)
  - [Consensus Algorithms](#consensus-algorithms)
  - [Fuzzing Compilers](#fuzzing-compilers)
  - [General](#general)
  - [Guidance](#guidance)
  - [Presentations](#presentations)
  - [Tooling](#tooling)
  - [Upgradeability](#upgradeability)
  - [Zero-Knowledge](#zero-knowledge)

## Consensus Algorithms

Research in the distributed systems area

| Date       | Title                                                                                                                                                                      | Description                                                                                                    |
| ---------- | -------------------------------------------------------------------------------------------------------------------------------------------------------------------------- | -------------------------------------------------------------------------------------------------------------- |
| 2021/11/11 | [Motivating global stabilization](https://blog.trailofbits.com/2021/11/11/motivating-global-stabilization/)                                                                | Review of Fischer, Lynch, and Paterson’s classic impossibility result and global stabilization time assumption |
| 2019/10/25 | [Formal Analysis of the CBC Casper Consensus Algorithm with TLA+](https://blog.trailofbits.com/2019/10/25/formal-analysis-of-the-cbc-casper-consensus-algorithm-with-tla/) | Verification of finality of the Correct By Construction (CBC) PoS consensus protocol                           |
| 2019/07/12 | [On LibraBFT’s use of broadcasts](https://blog.trailofbits.com/2019/07/12/librabft/)                                                                                       | Liveness of LibraBFT and HotStuff algorithms                                                                   |
| 2019/07/02 | [State of the Art Proof-of-Work: RandomX](https://blog.trailofbits.com/2019/07/02/state/)                                                                                  | Summary of our audit of ASIC and GPU-resistant PoW algorithm                                                   |
| 2018/10/12 | [Introduction to Verifiable Delay Functions (VDFs)](https://blog.trailofbits.com/2018/10/12/introduction-to-verifiable-delay-functions-vdfs/)                              | Basics of VDFs - a class of hard to compute, not parallelizable, but easily verifiable functions                |

## Fuzzing Compilers

Our work on the topic of fuzzing the `solc` compiler

| Date       | Title                                                                                                                                           | Description                         |
| ---------- | ----------------------------------------------------------------------------------------------------------------------------------------------- | ----------------------------------- |
| 2021/03/23 | [A Year in the Life of a Compiler Fuzzing Campaign](https://blog.trailofbits.com/2021/03/23/a-year-in-the-life-of-a-compiler-fuzzing-campaign/) | Results and features of fuzzing solc |
| 2020/06/05 | [Breaking the Solidity Compiler with a Fuzzer](https://blog.trailofbits.com/2020/06/05/breaking-the-solidity-compiler-with-a-fuzzer/)           | Our approach to fuzzing solc        |

## General

Security research, analyses, announcements, and write-ups

| Date       | Title                                                                                                                                                                          | Description                                                                                                                                                     |
| ---------- | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------ | --------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| 2022/10/12 | [Porting the Solana eBPF JIT compiler to ARM64](https://blog.trailofbits.com/2022/10/12/solana-jit-compiler-ebpf-arm64/)                                                       | A low-level write-up of the work done to make the Solana compiler work on ARM64                                                                                        |
| 2022/06/24 | [Managing risk in blockchain deployments](https://blog.trailofbits.com/2022/06/24/managing-risk-in-blockchain-deployments/)                                                    | A summary of the "Do You Really Need a Blockchain? An Operational Risk Assessment" report                                                                             |
| 2022/06/21 | [Are blockchains decentralized?](https://blog.trailofbits.com/2022/06/21/are-blockchains-decentralized/)                                                                       | A summary of the "Are Blockchains Decentralized? Unintended Centralities in Distributed Ledgers" report                                                                |
