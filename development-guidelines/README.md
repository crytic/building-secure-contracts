# Development Guidelines

The following recommendations describe high-level best pratices.

## Design Guidelines

The design of the contract should be discussed ahead of time, prior writing any line of code.

### Documentation and specification

Documentation can be written at different levels, and should be updated while implementing the contracts:

- **A plain English description of the system**, describing what the contracts do and any assumptions on the codebase.

- **Schema and architectural diagrams**, including the contracts interactions, and the state machine of the system. [Slither printers](https://github.com/crytic/slither/wiki/Printer-documentation) will help to generate these schemas.

- **Thorough code documentation**, the [Natspec format](https://solidity.readthedocs.io/en/develop/natspec-format.html) can be used for Solidity.

## Onchain vs Offchain computation

- **Put as much code as you can offchain.** Keep the onchain layer small. Rely on offchain code for any data pre-processing for which the result can be easily verified onchain. You need an ordered list? Sort the list offchain, and check only its order onchain.

## Upgradeability

We discussed the different upgradeability solutions in [our blogpost](https://blog.trailofbits.com/2018/09/05/contract-upgrade-anti-patterns/). The choice of upgradeable contract or not must be deliberate prior coding. The decision will influence how you structure our code. The summary is:

- **Favor [contract’s migration](https://blog.trailofbits.com/2018/10/29/how-contract-migration-works/) over upgradeability.** Migrations system have the same advantages than upgradeable, without their drawbacks.

- **Use the data separation pattern over the delegatecallproxy one.** If your project has a clear abstraction separation, upgradeability using the data separation pattern will necessitate only a few adjustments. The delegatecallproxy requires EVM expertise and is highly error-prone.

- **Document the migration/upgrade procedure before the deployment.** If you have to react under stress without any guidelines, you will make mistakes. Write the procedure to follow ahead of time. It should include:
  - What are the calls to make to initiate the new contracts.
  - Where are stored the keys, and how to access them.
  - How to check the deployment. A post-deployment script should be prepared, and fully tested.

# Implementation Guidelines

The main advice to keep in mind is to **strive for simplicity.** Always use the simplest solution that fits your purpose. Always keep in mind that anyone should be able to understand your solution.

## Function Composition

The architecture of your codebase will also heavily influence the ease to review your code.

- **Split the logic of your system**, either through multiple contracts or by grouping similar functions together (ex: authentification, arithmetic, …). It will ease targeting the features of the code

- **Write small functions, with a clear purpose.** Small code is simpler to review and allow the testing of individual components.

## Inheritance

- **Keep the inheritance manageable.** While inheritance should be used to divide the logic, your project should aim to minimize the depth and the width of the inheritance tree.

- **Use Slither’s [inheritance printer](https://github.com/crytic/slither/wiki/Printer-documentation#inheritance-graph) to check the contracts’ hierarchy.** The inheritance printer will help you to watch the hierarchy grows.

## Events

- **Log any crucial operation.** Events will help to debug the contract during the development, and monitor it after its deployment.

## Blockchain pitfalls

- **Be aware of the most common vulnerabilities patterns.** There are many online resources to learn about common issues, such as [Ethernaut CTF](https://ethernaut.openzeppelin.com/), [Capture the Ether](https://capturetheether.com/), or [Not so smart contract](https://github.com/crytic/not-so-smart-contracts/).

- **Be aware of the warnings sections in the [Solidity documentation](https://solidity.readthedocs.io/en/latest/).** The warnings sections will inform you about not obvious behavior of the language.

## Dependencies

- **Use well-tested libraries.** Importing code from well-tested libraries will reduce the likelihood for you to write buggy code. If you want to write an ERC20 contract, use [OpenZeppelin](https://github.com/OpenZeppelin/openzeppelin-contracts/tree/master/contracts/token/ERC20).

- **Use a dependencies manager, avoid copy-and-paste of code.** If you rely on an external source, be sure to be up to date with the original codebase.

## Testing and Verifying

- **Write thorough unit-tests.** An extensive test suite is crucial to build high-quality software. 

- **Write [Slither](https://github.com/crytic/slither), [Echidna](https://github.com/crytic/echidna) and [Manticore](https://github.com/trailofbits/manticore) custom checks and properties.** Automated tools will help you to ensure your contracts is secure. The content of this repository will help you to write efficient checks and properties.

- **Use [crytic.io](https://crytic.io/).** Crytic will give you access to Slither’s private detectors, and will provide github integration.

## Solidity

- **Favor Solidity 0.5 over 0.4 and 0.6.** Solidity 0.5 is overall more secure and has better inbuilt practices and 0.4. Solidity 0.6 is too young to be used in production.

- **Use a stable compiler’s version to compile, use the latest to check for warnings.** You should check that your code leads to no warning with the latest compiler version. Solidity compiler has a fast release cycle, and has a history of compiler bugs, as a result, we recommend to not use the latest version for deployment (see Slither’s [solc version recommendation](https://github.com/crytic/slither/wiki/Detector-Documentation#recommendation-33)).

- **Do not use inline assembly.** Assembly requires EVM expertise, if you do not master the yellow paper, do not write EVM code.

## Post development Guidelines

Once the contract has been developed, consider to:

- **Monitor your contracts.** Watch the contracts’ logs, and be ready to react in case of contracts or wallet compromise.

- **Add your contact info to [blockchain-security-contacts](https://github.com/crytic/blockchain-security-contacts).** The list will help third-parties to contact and coordinate with you if any security flaw is discovered.

- **Secure the wallets of privileged users.** Follow the [best practices](https://blog.trailofbits.com/2018/11/27/10-rules-for-the-secure-use-of-cryptocurrency-hardware-wallets/) to store the wallets.

- **Have a response to incident plan.** Take in consideration that you can be compromised. Even if your contracts are free of bugs, an attacker can take control of the contract’s owner keys.
