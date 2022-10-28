## General

Security research, analyses, guidances, and writeups

| Date | Title | Description |
|-----|-----|-----|
| 2022/10/12 | [Porting the Solana eBPF JIT compiler to ARM64](https://blog.trailofbits.com/2022/10/12/solana-jit-compiler-ebpf-arm64/) | Low-level writeup of the work done to make Solana compiler work on ARM64 |
| 2022/06/24 | [Managing risk in blockchain deployments](https://blog.trailofbits.com/2022/06/24/managing-risk-in-blockchain-deployments/) | Summary of "Do You Really Need a Blockchain? An Operational Risk Assessment" report |
| 2022/06/21 | [Are blockchains decentralized?](https://blog.trailofbits.com/2022/06/21/are-blockchains-decentralized/) | Summary of "Are Blockchains Decentralize? Unintended Centralities in Distributed Ledgers" report |
| 2021/02/05 | [Confessions of a smart contract paper reviewer](https://blog.trailofbits.com/2021/02/05/confessions-of-a-smart-contract-paper-reviewer/) | Six requirements for a good research paper |
| 2020/08/05 | [Accidentally stepping on a DeFi lego](https://blog.trailofbits.com/2020/08/05/accidentally-stepping-on-a-defi-lego/) | Writeup of a vulnerability in yVault project |
| 2020/05/15 | [Bug Hunting with Crytic](https://blog.trailofbits.com/2020/05/15/bug-hunting-with-crytic/) | Description of 9 bugs found by Crytic in public projects |
| 2019/10/24 | [Watch Your Language: Our First Vyper Audit](https://blog.trailofbits.com/2019/10/24/watch-your-language-our-first-vyper-audit/) | Pros and cons of Vyper language and disclosure of vulnerability in the Vyper's compiler |
| 2019/08/08 | [246 Findings From our Smart Contract Audits: An Executive Summary](https://blog.trailofbits.com/2019/08/08/246-findings-from-our-smart-contract-audits-an-executive-summary/) | Publication of data aggregated from our audits. Discussion about possibility of automatic and manual detection of vulnerabilities, and usefulness of unit tests |
| 2018/11/27 | [10 Rules for the Secure Use of Cryptocurrency Hardware Wallets](https://blog.trailofbits.com/2018/11/27/10-rules-for-the-secure-use-of-cryptocurrency-hardware-wallets/) | Recommendations for the secure use of hardware wallets. |
| 2018/04/06 | [How to prepare for a security review](https://blog.trailofbits.com/2018/04/06/how-to-prepare-for-a-security-audit/) | Checklist for before having a security audit |
| 2017/11/06 | [Hands on the Ethernaut CTF](https://blog.trailofbits.com/2017/11/06/hands-on-the-ethernaut-ctf/) | Solutions for six challenges |

## Tooling

Description of our tools and their use cases

| Date |  Tool | Title | Description |
|-----|-----|-----|-----|
| 2022/08/17 | <img src='https://raw.githubusercontent.com/crytic/slither/master/logo.png' alt='slither' width=100px /> | [Using mutants to improve Slither](https://blog.trailofbits.com/2022/08/17/using-mutants-to-improve-slither/) | Inserting random bugs into smart contracts and detecting them with various static analysis tools - to improve Slither's detectors |
| 2022/07/28 | <img src='https://raw.githubusercontent.com/crytic/slither/master/logo.png' alt='slither' width=100px /> | [Shedding smart contract storage with Slither](https://blog.trailofbits.com/2022/07/28/shedding-smart-contract-storage-with-slither/) | Announcement of the slither-read-storage tool |
| 2022/04/20 |  | [Amarna: Static analysis for Cairo programs](https://blog.trailofbits.com/2022/04/20/amarna-static-analysis-for-cairo-programs/) | Overview of Cairo footguns and announcement of the new static analysis tool |
| 2022/03/02 | <img src='https://raw.githubusercontent.com/crytic/echidna/master/echidna.png' alt='echidna' width=100px /> | [Optimizing a smart contract fuzzer](https://blog.trailofbits.com/2022/03/02/optimizing-a-smart-contract-fuzzer/) | Measuring and improving performance of Echidna (Haskell code) |
| 2021/12/16 | <img src='https://raw.githubusercontent.com/crytic/slither/master/logo.png' alt='slither' width=100px /> | [Detecting MISO and Opyn’s msg.value reuse vulnerability with Slither](https://blog.trailofbits.com/2021/12/16/detecting-miso-and-opyns-msg-value-reuse-vulnerability-with-slither/) | Description of Slither's new detectors: delegatecall-loop and msg-value-loop |
| 2021/04/02 |  | [Solar: Context-free, interactive analysis for Solidity](https://blog.trailofbits.com/2021/04/02/solar-context-free-interactive-analysis-for-solidity/) | Proof-of-concept static analysis framework |
| 2020/10/23 | <img src='https://raw.githubusercontent.com/crytic/slither/master/logo.png' alt='slither' width=100px /> | [Efficient audits with machine learning and Slither-simil](https://blog.trailofbits.com/2020/10/23/efficient-audits-with-machine-learning-and-slither-simil/) | Detect similar Solidity functions with Slither and ML |
| 2020/08/17 | <img src='https://raw.githubusercontent.com/crytic/echidna/master/echidna.png' alt='echidna' width=100px /> | [Using Echidna to test a smart contract library](https://blog.trailofbits.com/2020/08/17/using-echidna-to-test-a-smart-contract-library/) | Designing and testing properties with differential fuzzing |
| 2020/07/12 | <img src='https://raw.githubusercontent.com/trailofbits/manticore/master/docs/images/manticore.png' alt='manticore' width=100px /> | [Contract verification made easier](https://blog.trailofbits.com/2020/07/12/new-manticore-verifier-for-smart-contracts/) | Re-use Echidna properties with Manticore with manticore-verifier |
| 2020/06/12 | <img src='https://raw.githubusercontent.com/crytic/slither/master/logo.png' alt='slither' width=100px /> | [Upgradeable contracts made safer with Crytic](https://blog.trailofbits.com/2020/06/12/upgradeable-contracts-made-safer-with-crytic/) | 17 new Slither detectors for upgradeable contracts |
| 2020/03/30 | <img src='https://raw.githubusercontent.com/crytic/echidna/master/echidna.png' alt='echidna' width=100px /> | [An Echidna for all Seasons](https://blog.trailofbits.com/2020/03/30/an-echidna-for-all-seasons/) | Announcement of new features in Echidna |
| 2020/03/03 | <img src='https://raw.githubusercontent.com/trailofbits/manticore/master/docs/images/manticore.png' alt='manticore' width=100px /> | [Manticore discovers the ENS bug](https://blog.trailofbits.com/2020/03/03/manticore-discovers-the-ens-bug/) | Using symbolic analysis to find vulnerability in Ethereum Name Service contract |
| 2020/01/31 | <img src='https://raw.githubusercontent.com/trailofbits/manticore/master/docs/images/manticore.png' alt='manticore' width=100px /> | [Symbolically Executing WebAssembly in Manticore](https://blog.trailofbits.com/2020/01/31/symbolically-executing-webassembly-in-manticore/) | Using symbolic analysis on an artificial WASM binary |
| 2019/08/02 |  | [Crytic: Continuous Assurance for Smart Contracts](https://blog.trailofbits.com/2019/08/02/crytic-continuous-assurance-for-smart-contracts/) | New product that integrates static analysis with GitHub pipeline |
| 2019/07/03 | <img src='https://raw.githubusercontent.com/crytic/slither/master/logo.png' alt='slither' width=100px /> | [Avoiding Smart Contract \"Gridlock\" with Slither](https://blog.trailofbits.com/2019/07/03/avoiding-smart-contract-gridlock-with-slither/) | Description of a DoS vulnerability resulting from a strict equality check, and Slither's dangerous-strict-equality detector |
| 2019/05/27 | <img src='https://raw.githubusercontent.com/crytic/slither/master/logo.png' alt='slither' width=100px /> | [Slither: The Leading Static Analyzer for Smart Contracts](https://blog.trailofbits.com/2019/05/27/slither-the-leading-static-analyzer-for-smart-contracts/) | Slither design and comparison with other static analysis tools |
| 2018/10/19 | <img src='https://raw.githubusercontent.com/crytic/slither/master/logo.png' alt='slither' width=100px /> | [Slither – a Solidity static analysis framework](https://blog.trailofbits.com/2018/10/19/slither-a-solidity-static-analysis-framework/) | Introduction to Slither's API and printers |
| 2018/09/06 | <img src='https://raw.githubusercontent.com/crytic/rattle/master/logo_s.png' alt='rattle' width=100px /> | [Rattle – an Ethereum EVM binary analysis framework](https://blog.trailofbits.com/2018/09/06/rattle-an-ethereum-evm-binary-analysis-framework/) | Turn EVM bytecode to infinite-register SSA form |
| 2018/05/03 | <img src='https://raw.githubusercontent.com/crytic/echidna/master/echidna.png' alt='echidna' width=100px /> | [State Machine Testing with Echidna](https://blog.trailofbits.com/2018/05/03/state-machine-testing-with-echidna/) | Example use case of Echidna's Haskell API |
| 2018/03/23 |  | [Use our suite of Ethereum security tools](https://blog.trailofbits.com/2018/03/23/use-our-suite-of-ethereum-security-tools/) | Overview of our tools and documents: Not So Smart Contracts, Slither, Echidna, Manticore, EVM Opcode Database, Ethersplay, IDA-EVM, Rattle |
| 2018/03/09 | <img src='https://raw.githubusercontent.com/crytic/echidna/master/echidna.png' alt='echidna' width=100px /> | [Echidna, a smart fuzzer for Ethereum](https://blog.trailofbits.com/2018/03/09/echidna-a-smart-fuzzer-for-ethereum/) | First release and introduction to Echidna |
| 2017/04/27 | <img src='https://raw.githubusercontent.com/trailofbits/manticore/master/docs/images/manticore.png' alt='manticore' width=100px /> | [Manticore: Symbolic execution for humans](https://blog.trailofbits.com/2017/04/27/manticore-symbolic-execution-for-humans/) | First release and introduction to Manticore (not adopted for EVM yet) |

## Upgradeability

Our work related to contracts upgradeability

| Date | Title | Description |
|-----|-----|-----|
| 2020/12/16 | [Breaking Aave Upgradeability](https://blog.trailofbits.com/2020/12/16/breaking-aave-upgradeability/) | Description of Delegatecall Proxy vulnerability in formally-verified Aave contracts |
| 2020/10/30 | [Good idea, bad design: How the Diamond standard falls short](https://blog.trailofbits.com/2020/10/30/good-idea-bad-design-how-the-diamond-standard-falls-short/) | Audit of Diamond standard's implementation |
| 2018/10/29 | [How contract migration works](https://blog.trailofbits.com/2018/10/29/how-contract-migration-works/) | Alternative to upgradability mechanism - moving data to a new contract |
| 2018/09/05 | [Contract upgrade anti-patterns](https://blog.trailofbits.com/2018/09/05/contract-upgrade-anti-patterns/) | Discussion of risks and recommendations for Data Separation and Delegatecall Proxy patterns. Disclosure of vulnerability in Zeppelin Proxy contract. |

## Consensus algorithms

Research in the distributes systems area

| Date | Title | Description |
|-----|-----|-----|
| 2021/11/11 | [Motivating global stabilization](https://blog.trailofbits.com/2021/11/11/motivating-global-stabilization/) | Review of Fischer, Lynch, and Paterson’s classic impossibility result and global stabilization time assumption |
| 2019/10/25 | [Formal Analysis of the CBC Casper Consensus Algorithm with TLA+](https://blog.trailofbits.com/2019/10/25/formal-analysis-of-the-cbc-casper-consensus-algorithm-with-tla/) | Verification of finality of the Correct By Construction (CBC) PoS consensus protocol |
| 2019/07/12 | [On LibraBFT’s use of broadcasts](https://blog.trailofbits.com/2019/07/12/librabft/) | Liveness of LibraBFT and HotStuff algorithms |
| 2019/07/02 | [State of the Art Proof-of-Work: RandomX](https://blog.trailofbits.com/2019/07/02/state/) | Summary of our audit of ASIC and GPU-resistant PoW algorithm |
| 2018/10/12 | [Introduction to Verifiable Delay Functions (VDFs)](https://blog.trailofbits.com/2018/10/12/introduction-to-verifiable-delay-functions-vdfs/) | Basics of VDFs - a class of hard to compute, not paralelizable, but easily verifiable functions |

## Announcements

Notes of something we did or are planning to do

| Date | Title | Description |
|-----|-----|-----|
| 2020/04/23 | [Announcing the 1st International Workshop on Smart Contract Analysis](https://blog.trailofbits.com/2020/04/23/announcing-the-1st-international-workshop-on-smart-contract-analysis/) | Workshop co-organized with Northern Arizona University and co-located with ISSTA 2020 |
| 2019/12/09 | [Mainnet360: joint economic and security reviews with Prysm Group](https://blog.trailofbits.com/2019/12/09/introducing-mainnet360-a-joint-economic-and-security-assessment-with-prysm-group/) |  |
| 2019/11/13 | [Announcing the Crytic $10k Research Prize](https://blog.trailofbits.com/2019/11/13/announcing-the-crytic-10k-research-prize/) |  |
| 2018/11/19 | [Return of the Blockchain Security Empire Hacking](https://blog.trailofbits.com/2018/11/19/return-of-the-blockchain-security-empire-hacking/) |  |
| 2018/10/04 | [Ethereum security guidance for all](https://blog.trailofbits.com/2018/10/04/ethereum-security-guidance-for-all/) | Announcement of office hours, Blockchain Security Contacts, and Awesome Ethereum Security |
| 2018/02/09 | [Parity Technologies engages Trail of Bits](https://blog.trailofbits.com/2018/02/09/parity-technologies-engages-trail-of-bits/) |  |
| 2017/10/19 | [Trail of Bits joins the Enterprise Ethereum Alliance](https://blog.trailofbits.com/2017/10/19/trail-of-bits-joins-the-enterprise-ethereum-alliance/) | The first blockchain blogpost; announcement of OSS tools. |

## Presentations

Talks, videos, and slides

| Date | Title | Description |
|-----|-----|-----|
| 2019/01/18 | [Empire Hacking: Ethereum Edition 2](https://blog.trailofbits.com/2019/01/18/empire-hacking-ethereum-edition-2/) | Talks include: `Anatomy of an unsafe smart contract programming language`, `Evaluating digital asset security fundamentals`, `Contract upgrade risks and recommendations`, `How to buidl an enterprise-grade mainnet Ethereum client`, `Failures in on-chain privacy`, `Secure micropayment protocols`, `Designing the Gemini dollar: a regulated, upgradeable, transparent stablecoin`, `Property testing with Echidna and Manticore for secure smart contracts`, `Simple is hard: Making your awesome security thing usable` |
| 2018/11/16 | [Trail of Bits @ Devcon IV Recap](https://blog.trailofbits.com/2018/11/16/trail-of-bits-devcon-iv-recap/) | Talks include: `Using Manticore and Symbolic Execution to Find Smart Contract Bugs`, `Blockchain Autopsies`, `Current State of Security` |
| 2017/12/22 | [Videos from Ethereum-focused Empire Hacking](https://blog.trailofbits.com/2017/12/22/videos-from-ethereum-focused-empire-hacking/) | Talks include: `A brief history of smart contract security`, `A CTF Field Guide for smart contracts`, `Automatic bug finding for the blockchain`, `Addressing infosec needs with blockchain technology` |

## ZKP

Our work in Zero-Knowledge Proofs space

| Date | Title | Description |
|-----|-----|-----|
| 2022/04/18 | [The Frozen Heart vulnerability in PlonK](https://blog.trailofbits.com/2022/04/18/the-frozen-heart-vulnerability-in-plonk/) |  |
| 2022/04/15 | [The Frozen Heart vulnerability in Bulletproofs](https://blog.trailofbits.com/2022/04/15/the-frozen-heart-vulnerability-in-bulletproofs/) |  |
| 2022/04/14 | [The Frozen Heart vulnerability in Girault’s proof of knowledge](https://blog.trailofbits.com/2022/04/14/the-frozen-heart-vulnerability-in-giraults-proof-of-knowledge/) |  |
| 2022/04/13 | [Coordinated disclosure of vulnerabilities affecting Girault, Bulletproofs, and PlonK](https://blog.trailofbits.com/2022/04/13/part-1-coordinated-disclosure-of-vulnerabilities-affecting-girault-bulletproofs-and-plonk/) | Introducing new "Frozen Heart" class of vulnerabilities |
| 2021/12/21 | [Disclosing Shamir’s Secret Sharing vulnerabilities and announcing ZKDocs](https://blog.trailofbits.com/2021/12/21/disclosing-shamirs-secret-sharing-vulnerabilities-and-announcing-zkdocs/) |  |
| 2021/02/19 | [Serving up zero-knowledge proofs](https://blog.trailofbits.com/2021/02/19/serving-up-zero-knowledge-proofs/) | Fiat-Shamir transformation explained |
| 2020/12/14 | [Reverie: An optimized zero-knowledge proof system](https://blog.trailofbits.com/2020/12/14/reverie-an-optimized-zero-knowledge-proof-system/) | Rust implementation of the MPC-in-the-head proof system |
| 2020/05/21 | [Reinventing Vulnerability Disclosure using Zero-knowledge Proofs](https://blog.trailofbits.com/2020/05/21/reinventing-vulnerability-disclosure-using-zero-knowledge-proofs/) | Announcement of DARPA sponsored work on ZK proofs of exploitability |
| 2019/10/04 | [Multi-Party Computation on Machine Learning](https://blog.trailofbits.com/2019/10/04/multi-party-computation-on-machine-learning/) | Implementation of 3-party computation protocol for perceptron and support vector machine (SVM) algorithms |

## Fuzzing compilers

Our work in the topic of fuzzing the `solc` compiler

| Date | Title | Description |
|-----|-----|-----|
| 2021/03/23 | [A Year in the Life of a Compiler Fuzzing Campaign](https://blog.trailofbits.com/2021/03/23/a-year-in-the-life-of-a-compiler-fuzzing-campaign/) | Results and feature of fuzzing solc |
| 2020/06/05 | [Breaking the Solidity Compiler with a Fuzzer](https://blog.trailofbits.com/2020/06/05/breaking-the-solidity-compiler-with-a-fuzzer/) | Our approach to fuzzing solc |
