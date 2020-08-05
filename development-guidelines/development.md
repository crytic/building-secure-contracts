# Development Guidelines

The following recommendations describe high-level best practices.

## Design Guidelines

The design of the contract should be discussed ahead of time, prior writing any line of code.

### Documentation and specification

Documentation can be written at different levels, and should be updated while implementing the contracts:

- **A plain English description of the system**, describing what the contracts do and any assumptions on the codebase.
- **Schema and architectural diagrams**, including the contract interactions and the state machine of the system. [Slither printers](https://github.com/crytic/slither/wiki/Printer-documentation) can help to generate these schemas.
- **Thorough code documentation**, the [Natspec format](https://solidity.readthedocs.io/en/develop/natspec-format.html) can be used for Solidity.

## On-chain vs off-chain computation

- **Keep as much code as you can off-chain.** Keep the on-chain layer small. Pre-process data with code off-chain in such a way that verification on-chain is simple. Do you need an ordered list? Sort the list offchain, then only check its order onchain.

## Upgradeability

We discussed the different upgradeability solutions in [our blogpost](https://blog.trailofbits.com/2018/09/05/contract-upgrade-anti-patterns/). Make a deliverate choice to support upgradeability or not prior to writing any code. The decision will influence how you structure our code. In general, we recommend:

- **Favoring [contract migration](https://blog.trailofbits.com/2018/10/29/how-contract-migration-works/) over upgradeability.** Migration system have many of the same advantages than upgradeable, without their drawbacks.
- **Using the data separation pattern over the delegatecallproxy one.** If your project has a clear abstraction separation, upgradeability using data separation will necessitate only a few adjustments. The delegatecallproxy requires EVM expertise and is highly error-prone.
- **Document the migration/upgrade procedure before the deployment.** If you have to react under stress without any guidelines, you will make mistakes. Write the procedure to follow ahead of time. It should include:
  - The calls that initiate the new contracts
  - Where are stored the keys and how to access them
  - How to check the deployment! Develop and test a post-deployment script.
  
