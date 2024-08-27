# Development Guidelines

Follow these high-level recommendations to build more secure smart contracts.

- [Development Guidelines](#development-guidelines)
  - [Design Guidelines](#design-guidelines)
    - [Documentation and Specifications](#documentation-and-specifications)
    - [On-chain vs Off-chain Computation](#on-chain-vs-off-chain-computation)
    - [Upgradeability](#upgradeability)
      - [Delegatecall Proxy](#delegatecall-proxy-pattern)
  - [Implementation Guidelines](#implementation-guidelines)
    - [Function Composition](#function-composition)
    - [Inheritance](#inheritance)
    - [Events](#events)
    - [Avoid Known Pitfalls](#avoid-known-pitfalls)
    - [Dependencies](#dependencies)
    - [Testing and Verification](#testing-and-verification)
    - [Solidity](#solidity)
  - [Deployment Guidelines](#deployment-guidelines)

## Design Guidelines

Discuss the design of the contract ahead of time, before writing any code.

### Documentation and Specifications

Write documentation at different levels and update it as you implement the contracts:

- **A plain English description of the system**, describing the contracts' purpose and any assumptions about the codebase.
- **Schema and architectural diagrams**, including contract interactions and the system's state machine. Use [Slither printers](https://github.com/crytic/slither/wiki/Printer-documentation) to help generate these schemas.
- **Thorough code documentation**. Use the [Natspec format](https://solidity.readthedocs.io/en/develop/natspec-format.html) for Solidity.

### On-chain vs Off-chain Computation

- **Keep as much code off-chain as possible.** Keep the on-chain layer small. Pre-process data off-chain in a way that simplifies on-chain verification. Need an ordered list? Sort it off-chain, then check its order on-chain.

### Upgradeability

Refer to [our blog post](https://blog.trailofbits.com/2018/09/05/contract-upgrade-anti-patterns/) for different upgradeability solutions. If you are using delegatecall to achieve upgradability, carefully review all items of the delegatecall proxy guidance. Decide whether or not to support upgradeability before writing any code, as this decision will affect your code's structure. Generally, we recommend:

- **Favoring [contract migration](https://blog.trailofbits.com/2018/10/29/how-contract-migration-works/) over upgradeability.** Migration systems offer many of the same advantages as upgradeable systems but without their drawbacks.
- **Using the data separation pattern instead of the delegatecall proxy pattern.** If your project has a clear abstraction separation, upgradeability using data separation will require only a few adjustments. The delegatecall proxy is highly error-prone and demands EVM expertise.
- **Document the migration/upgrade procedure before deployment.** Write the procedure to follow ahead of time to avoid errors when reacting under stress. It should include:
  - The calls that initiate new contracts
  - The keys' storage location and access method
  - Deployment verification: develop and test a post-deployment script.

#### Delegatecall Proxy Pattern

The delegatecall opcode is a sharp tool that must be used carefully. Many high-profile exploits involve little-known edge cases and counter-intuitive aspects of the delegatecall proxy pattern. To aid the development of secure delegatecall proxies, utilize the [slither-check-upgradability](https://github.com/crytic/slither/wiki/Upgradeability-Checks) tool, which performs safety checks for both upgradable and immutable delegatecall proxies.

- **Storage layout**: Proxy and implementation storage layouts must be the same. Instead of defining the same state variables for each contract, both should inherit all state variables from a shared base contract.
- **Inheritance**: Be aware that the order of inheritance affects the final storage layout. For example, `contract A is B, C` and `contract A is C, B` will not have the same storage layout if both B and C define state variables.
- **Initialization**: Immediately initialize the implementation. Well-known disasters (and near disasters) have featured an uninitialized implementation contract. A factory pattern can help ensure correct deployment and initialization and reduce front-running risks.
- **Function shadowing**: If the same method is defined on the proxy and the implementation, then the proxy’s function will not be called. Be mindful of `setOwner` and other administration functions commonly found on proxies.
- **Direct implementation usage**: Configure implementation state variables with values that prevent direct use, such as setting a flag during construction that disables the implementation and causes all methods to revert. This is particularly important if the implementation also performs delegatecall operations, as this may lead to unintended self-destruction of the implementation.
- **Immutable and constant variables**: These variables are embedded in the bytecode and can get out of sync between the proxy and implementation. If the implementation has an incorrect immutable variable, this value may still be used even if the same variable is correctly set in the proxy’s bytecode.
- **Contract Existence Checks**: All [low-level calls](https://docs.soliditylang.org/en/latest/control-structures.html?highlight=existence#error-handling-assert-require-revert-and-exceptions), including delegatecall, return true for an address with empty bytecode. This can mislead callers into thinking a call performed a meaningful operation when it did not or cause crucial safety checks to be skipped. While a contract’s constructor runs, its bytecode remains empty until the end of execution. We recommend rigorously verifying that all low-level calls are protected against nonexistent contracts. Keep in mind that most proxy libraries (such as Openzeppelin's) do not automatically perform contract existence checks.

For more information on delegatecall proxies, consult our blog posts and presentations:

- [Contract Upgradability Anti-Patterns](https://blog.trailofbits.com/2018/09/05/contract-upgrade-anti-patterns/): Describes the differences between downstream data contracts and delegatecall proxies with upstream data contracts and how these patterns affect upgradability.
- [How the Diamond Standard Falls Short](https://blog.trailofbits.com/2020/10/30/good-idea-bad-design-how-the-diamond-standard-falls-short/): Explores delegatecall risks that apply to all contracts, not just those following the diamond standard.
- [Breaking Aave Upgradeability](https://blog.trailofbits.com/2020/12/16/breaking-aave-upgradeability/): Discusses a subtle problem we discovered in Aave `AToken` contracts, resulting from the interplay between delegatecall proxies, contract existence checks, and unsafe initialization.
- [Contract Upgrade Risks and Recommendations](https://youtu.be/mebA5Qz9zeQ?t=353): A Trail of Bits talk on best practices for developing upgradable delegatecall proxies. The section starting at 5:49 describes general risks for non-upgradable proxies.

## Implementation Guidelines

**Aim for simplicity.** Use the simplest solution that meets your needs. Any member of your team should understand your solution.

### Function Composition

Design your codebase architecture to facilitate easy review and allow testing individual components:

- **Divide the system's logic**, either through multiple contracts or by grouping similar functions together (e.g. authentication, arithmetic).
- **Write small functions with clear purposes.**

### Inheritance

- **Keep inheritance manageable.** Though inheritance can help divide logic you should aim to minimize the depth and width of the inheritance tree.
- **Use Slither’s [inheritance printer](https://github.com/crytic/slither/wiki/Printer-documentation#inheritance-graph) to check contract hierarchies.** The inheritance printer can help review the hierarchy size.

### Events

- **Log all critical operations.** Events facilitate contract debugging during development and monitoring after deployment.

### Avoid Known Pitfalls

- **Be aware of common security issues.** Many online resources can help, such as [Ethernaut CTF](https://ethernaut.openzeppelin.com/), [Capture the Ether](https://capturetheether.com/), and [Not So Smart Contracts](https://github.com/crytic/not-so-smart-contracts/).
- **Review the warnings sections in the [Solidity documentation](https://solidity.readthedocs.io/en/latest/).** These sections reveal non-obvious language behaviors.

### Dependencies

- **Use well-tested libraries.** Importing code from well-tested libraries reduces the likelihood of writing buggy code. If writing an ERC20 contract, use [OpenZeppelin](https://github.com/OpenZeppelin/openzeppelin-contracts/tree/master/contracts/token/ERC20).
- **Use a dependency manager instead of copying and pasting code.** Always keep external sources up-to-date.

### Testing and Verification

- **Create thorough unit tests.** An extensive test suite is essential for developing high-quality software.
- **Develop custom [Slither](https://github.com/crytic/slither) and [Echidna](https://github.com/crytic/echidna) checks and properties.** Automated tools help ensure contract security. Review the rest of this guide to learn how to write efficient checks and properties.

### Solidity

- **Favor Solidity versions outlined in our [Slither Recommendations](https://github.com/crytic/slither/wiki/Detector-Documentation#incorrect-versions-of-solidity)**. We believe older Solidity versions are more secure and have better built-in practices. Newer versions may be too immature for production and need time to develop.
- **Compile using a stable release, but check for warnings with the latest release.** Verify that the latest compiler version reports no issues with your code. However, since Solidity has a fast release cycle and a history of compiler bugs, we do not recommend the newest version for deployment. See Slither’s [solc version recommendation](https://github.com/crytic/slither/wiki/Detector-Documentation#incorrect-versions-of-solidity).
- **Avoid inline assembly.** Assembly requires EVM expertise. Do not write EVM code unless you have _mastered_ the yellow paper.

## Deployment Guidelines

After developing and deploying the contract:

- **Monitor contracts.** Observe logs and be prepared to respond in the event of contract or wallet compromise.
- **Add contact information to [blockchain-security-contacts](https://github.com/crytic/blockchain-security-contacts).** This list helps third parties notify you of discovered security flaws.
- **Secure privileged users' wallets.** Follow our [best practices](https://blog.trailofbits.com/2018/11/27/10-rules-for-the-secure-use-of-cryptocurrency-hardware-wallets/) for hardware wallet key storage.
- **Develop an incident response plan.** Assume your smart contracts can be compromised. Possible threats include contract bugs or attackers gaining control of the contract owner's keys.
