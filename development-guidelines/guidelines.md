# Development Guidelines

Follow these high-level recommendations to build more secure smart contracts.

- [Development Guidelines](#development-guidelines)
  - [Design guidelines](#design-guidelines)
    - [Documentation and specifications](#documentation-and-specifications)
    - [On-chain vs off-chain computation](#on-chain-vs-off-chain-computation)
    - [Upgradeability](#upgradeability)
      - [Delegatecall Proxy](#delegatecall-proxy-pattern)
  - [Implementation guidelines](#implementation-guidelines)
    - [Function composition](#function-composition)
    - [Inheritance](#inheritance)
    - [Events](#events)
    - [Avoid known pitfalls](#avoid-known-pitfalls)
    - [Dependencies](#dependencies)
    - [Testing and verification](#testing-and-verification)
    - [Solidity](#solidity)
  - [Deployment guidelines](#deployment-guidelines)

## Design guidelines

The design of the contract should be discussed ahead of time, prior writing any line of code.

### Documentation and specifications

Documentation can be written at different levels, and should be updated while implementing the contracts:

- **A plain English description of the system**, describing what the contracts do and any assumptions on the codebase.
- **Schema and architectural diagrams**, including the contract interactions and the state machine of the system. [Slither printers](https://github.com/crytic/slither/wiki/Printer-documentation) can help to generate these schemas.
- **Thorough code documentation**, the [Natspec format](https://solidity.readthedocs.io/en/develop/natspec-format.html) can be used for Solidity.

### On-chain vs off-chain computation

- **Keep as much code as you can off-chain.** Keep the on-chain layer small. Pre-process data with code off-chain in such a way that verification on-chain is simple. Do you need an ordered list? Sort the list off-chain, then only check its order onchain.

### Upgradeability

We discussed the different upgradeability solutions in [our blog post](https://blog.trailofbits.com/2018/09/05/contract-upgrade-anti-patterns/). In particular, if you are using delegatecall to achieve upgradability, carefully review all items of the above delegatecall proxy guidance. Make a deliberate choice to support upgradeability or not prior to writing any code. The decision will influence how you structure our code. In general, we recommend:

- **Favoring [contract migration](https://blog.trailofbits.com/2018/10/29/how-contract-migration-works/) over upgradeability.** Migration system have many of the same advantages than upgradeable, without their drawbacks.
- **Using the data separation pattern over the delegatecall proxy one.** If your project has a clear abstraction separation, upgradeability using data separation will necessitate only a few adjustments. The delegatecall proxy requires EVM expertise and is highly error-prone.
- **Document the migration/upgrade procedure before the deployment.** If you have to react under stress without any guidelines, you will make mistakes. Write the procedure to follow ahead of time. It should include:
  - The calls that initiate the new contracts
  - Where are stored the keys and how to access them
  - How to check the deployment! Develop and test a post-deployment script.

#### Delegatecall Proxy Pattern

The delegatecall opcode is a very sharp tool that must be used carefully. Many high-profile exploits utilize little-known edge cases and counter-intuitive aspects of the delegatecall proxy pattern. This section aims to outline the most important risks to keep in mind while developing such smart contract systems. Trail of Bits developed the [slither-check-upgradability](https://github.com/crytic/slither/wiki/Upgradeability-Checks) tool to aid in the development of secure delegatecall proxies, it performs safety checks relevant to both upgradable and immutable delegatecall proxies.

- **Storage layout**: The storage layout of the proxy and implementation must be the same. Do not try to define the same state variables on each contract. Instead, both contracts should inherit all of their state variables from one shared base contract.
- **Inheritance**: If the base storage contract is split up, beware that the order of inheritance impacts the final storage layout. For example, `contract A is B,C` and `contract A is C,B` will not yield the same storage layout if both B and C define state variables.
- **Initialization**: Make sure that the implementation is immediately initialized. Well-known disasters (and near disasters) have featured an uninitialized implementation contract. A factory pattern can help ensure that contracts are deployed & initialized correctly while also mitigating front-running risks that might otherwise open up between contract deployment & initialization.
- **Function shadowing**: If the same method is defined on the proxy and the implementation, then the proxy’s function will not be called. Be aware of `setOwner` and other administration functions that commonly exist on proxies.
- **Direct implementation usage**: Consider configuring the implementation’s state variables with values that prevent it from being used directly, such as by setting a flag during construction that disables the implementation and causes all methods to revert. This is particularly important if the implementation also performs delegatecall operations because this opens up the possibility of unintended self destruction of the implementation.
- **Immutable and constant variables**: These are embedded into the bytecode and can therefore get out of sync between the proxy and implementation. If the implementation has an incorrect immutable variable, this value may still be used even if the same variables are correctly set in the proxy’s bytecode.
- **Contract Existence Checks**: All [low-level calls](https://docs.soliditylang.org/en/latest/control-structures.html?highlight=existence#error-handling-assert-require-revert-and-exceptions), not just delegatecall, will return true against an address with empty bytecode. This might cause callers to be misled to think that a call performed a meaningful operation when it did not or it might result in important safety checks being silently skipped. Be aware that while a contract’s constructor is running, its bytecode remains empty until the end of constructor execution. We recommend that you rigorously verify that all low-level calls are properly protected against nonexistent contracts, keeping in mind that most proxy libraries (such as the one written by Openzeppelin) do not perform contract existence checks automatically.

For more information regarding delegatecall proxies in general, reference our blog posts and presentations:

- [Contract Upgradability Anti-Patterns](https://blog.trailofbits.com/2018/09/05/contract-upgrade-anti-patterns/): Describes the difference between a downstream data contract and delegatecall proxies which use an upstream data contract and how these patterns impact upgradability.
- [How the Diamond standard falls short](https://blog.trailofbits.com/2020/10/30/good-idea-bad-design-how-the-diamond-standard-falls-short/): This post dives deep into delegatecall risks which apply to all contracts, not just those that follow the diamond standard.
- [Breaking Aave Upgradeability](https://blog.trailofbits.com/2020/12/16/breaking-aave-upgradeability/): A write-up describing a subtle problem that we discovered in Aave `AToken` contracts that resulted from the interplay between delegatecall proxies, contact existence checks, and unsafe initialization.
- [Contract Upgrade Risks and Recommendations](https://youtu.be/mebA5Qz9zeQ?t=353): A talk by Trail of Bits describing best-practices for developing upgradable delegatecall proxies. The section starting at 5:49 describes some general risks that also apply to non-upgradable proxies.

## Implementation guidelines

**Strive for simplicity.** Always use the simplest solution that fits your purpose. Any member of your team should be able to understand your solution.

### Function composition

The architecture of your codebase should make your code easy to review. Avoid architectural choices that decrease the ability to reason about its correctness.

- **Split the logic of your system**, either through multiple contracts or by grouping similar functions together (for example, authentication, arithmetic, ...).
- **Write small functions, with a clear purpose.** This will facilitate easier review and allow the testing of individual components.

### Inheritance

- **Keep the inheritance manageable.** Inheritance should be used to divide the logic, however, your project should aim to minimize the depth and width of the inheritance tree.
- **Use Slither’s [inheritance printer](https://github.com/crytic/slither/wiki/Printer-documentation#inheritance-graph) to check the contracts’ hierarchy.** The inheritance printer will help you review the size of the hierarchy.

### Events

- **Log all crucial operations.** Events will help to debug the contract during the development, and monitor it after deployment.

### Avoid known pitfalls

- **Be aware of the most common security issues.** There are many online resources to learn about common issues, such as [Ethernaut CTF](https://ethernaut.openzeppelin.com/), [Capture the Ether](https://capturetheether.com/), or [Not so smart contracts](https://github.com/crytic/not-so-smart-contracts/).
- **Be aware of the warnings sections in the [Solidity documentation](https://solidity.readthedocs.io/en/latest/).** The warnings sections will inform you about non-obvious behavior of the language.

### Dependencies

- **Use well-tested libraries.** Importing code from well-tested libraries will reduce the likelihood that you write buggy code. If you want to write an ERC20 contract, use [OpenZeppelin](https://github.com/OpenZeppelin/openzeppelin-contracts/tree/master/contracts/token/ERC20).
- **Use a dependency manager; avoid copy-pasting code.** If you rely on an external source, then you must keep it up-to-date with the original source.

### Testing and verification

- **Write thorough unit-tests.** An extensive test suite is crucial to build high-quality software.
- **Write [Slither](https://github.com/crytic/slither) and [Echidna](https://github.com/crytic/echidna) custom checks and properties.** Automated tools will help ensure your contract is secure. Review the rest of this guide to learn how to write efficient checks and properties.

### Solidity

- **Favor Solidity versions outlined in our [Slither Recommendations](https://github.com/crytic/slither/wiki/Detector-Documentation#incorrect-versions-of-solidity)** In our opinion, older Solidity are more secure and have better built-in practices. Newer Solidity versions may be too young to be used in production and require additional time to mature.
- **Use a stable release to compile; use the latest release to check for warnings.** Check that your code has no reported issues with the latest compiler version. However, Solidity has a fast release cycle and has a history of compiler bugs, so we do not recommend the latest version for deployment (see Slither’s [solc version recommendation](https://github.com/crytic/slither/wiki/Detector-Documentation#incorrect-versions-of-solidity)).
- **Do not use inline assembly.** Assembly requires EVM expertise. Do not write EVM code if you have not _mastered_ the yellow paper.

## Deployment guidelines

Once the contract has been developed and deployed:

- **Monitor your contracts.** Watch the logs, and be ready to react in case of contract or wallet compromise.
- **Add your contact info to [blockchain-security-contacts](https://github.com/crytic/blockchain-security-contacts).** This list helps third-parties contact you if a security flaw is discovered.
- **Secure the wallets of privileged users.** Follow our [best practices](https://blog.trailofbits.com/2018/11/27/10-rules-for-the-secure-use-of-cryptocurrency-hardware-wallets/) if you store keys in hardware wallets.
- **Have a response to incident plan.** Consider that your smart contracts can be compromised. Even if your contracts are free of bugs, an attacker may take control of the contract owner's keys.
