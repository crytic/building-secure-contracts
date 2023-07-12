# Building Secure Smart Contracts - Devcon Edition

The slides are TBD.

## Install Echidna

- On MacOs: `brew install echidna`
- On other systems: download from https://github.com/crytic/echidna/releases/tag/v2.2.0

Consider using [eth-security-toolbox](https://github.com/trailofbits/eth-security-toolbox/) (docker) if you have troubles running Echidna.

## Exercises

- [Exercise 1](program-analysis/echidna/exercises/Exercise-1.md)
- [Exercise 2](program-analysis/echidna/exercises/Exercise-2.md)
- [Exercise 4](program-analysis/echidna/exercises/Exercise-4.md)
- [Exercise 5](program-analysis/echidna/exercises/Exercise-5.md)
- [Exercise 6](program-analysis/echidna/exercises/Exercise-6.md)

## Additional information

Consider using [solc-select](https://github.com/crytic/solc-select) to easily switch Solidity versions:

- `pip3 install solc-select`: to install it
- `solc-select install 0.8.0`: to install solc `0.8.0`
- `solc-select use 0.8.0`: to switch to solc `0.8.0`

[secure-contracts.com](https://secure-contracts.com/) contains additional exercises and guidelines that won't be covered during the workshop.
