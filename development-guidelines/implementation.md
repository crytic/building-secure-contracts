#  Implementation Guidelines

**Strive for simplicity.** Always use the simplest solution that fits your purpose. Any member of your team should be able to understand your solution.

## Function Composition

The architecture of your codebase should make your code easy to review. Avoid architectural choices that decrease the ability to reason about its correctness.

- **Split the logic of your system**, either through multiple contracts or by grouping similar functions together (for example, authentification, arithmetic, ...).
- **Write small functions, with a clear purpose.** This will facilitate easier review and allow the testing of individual components.

## Inheritance

- **Keep the inheritance manageable.** Inheritance should be used to divide the logic, however, your project should aim to minimize the depth and width of the inheritance tree.
- **Use Slither’s [inheritance printer](https://github.com/crytic/slither/wiki/Printer-documentation#inheritance-graph) to check the contracts’ hierarchy.** The inheritance printer will help you review the size of the hierarchy.

## Events

- **Log all crucial operations.** Events will help to debug the contract during the development, and monitor it after deployment.

## Blockchain pitfalls

- **Be aware of the most common security issues.** There are many online resources to learn about common issues, such as [Ethernaut CTF](https://ethernaut.openzeppelin.com/), [Capture the Ether](https://capturetheether.com/), or [Not so smart contracts](https://github.com/crytic/not-so-smart-contracts/).
- **Be aware of the warnings sections in the [Solidity documentation](https://solidity.readthedocs.io/en/latest/).** The warnings sections will inform you about non-obvious behavior of the language.

## Dependencies

- **Use well-tested libraries.** Importing code from well-tested libraries will reduce the likelihood that you write buggy code. If you want to write an ERC20 contract, use [OpenZeppelin](https://github.com/OpenZeppelin/openzeppelin-contracts/tree/master/contracts/token/ERC20).
- **Use a dependency manager; avoid copy-pasting code.** If you rely on an external source, then you must keep it up-to-date with the original source.

## Testing and Verifying

- **Write thorough unit-tests.** An extensive test suite is crucial to build high-quality software. 
- **Write [Slither](https://github.com/crytic/slither), [Echidna](https://github.com/crytic/echidna) and [Manticore](https://github.com/trailofbits/manticore) custom checks and properties.** Automated tools will help ensure your contract is secure. Continue with this guide to learn how to write efficient checks and properties.
- **Use [crytic.io](https://crytic.io/).** Crytic integrates with Github, provides access to Slither’s private detectors, runs custom property checks from Echidna.

## Solidity

- **Favor Solidity 0.5 over 0.4 and 0.6.** In our opinion, Solidity 0.5 is more secure and has better built-in practices than 0.4. Solidity 0.6 has proven too unstable for production and needs time to mature.
- **Use a stable release to compile; use the latest release to check for warnings.** Check that your code has no reported issues with the latest compiler version. However, Solidity has a fast release cycle and has a history of compiler bugs, so we do recommend the latest version for deployment (see Slither’s [solc version recommendation](https://github.com/crytic/slither/wiki/Detector-Documentation#recommendation-33)).
- **Do not use inline assembly.** Assembly requires EVM expertise. Do not write EVM code if you have not _mastered_ the yellow paper.

