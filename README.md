# Building Secure Smart Contracts - DappCon Edition


## Install Echidna
- On MacOs: `brew install echidna`
- On other systems: download from https://github.com/crytic/echidna/releases/tag/v2.0.3

Consider using [eth-security-toolbox](https://github.com/trailofbits/eth-security-toolbox/) (docker) if you have troubles running Echidna.

## Exercises
- [Exercise 1](program-analysis/echidna/Exercise-1.md)
- [Exercise 2](program-analysis/echidna/Exercise-2.md)

## Additional information
Consider using [solc-select](https://github.com/crytic/solc-select) to easily switch Solidity versions:
- `pip3 install solc-select`: to install it
- `solc-select install 0.7.0`: to install solc `0.7.0`
- `solc-select use 0.7.0`: to switch to solc `0.7.0`

[Building-secure-contracts](https://github.com/crytic/building-secure-contracts) contains additional exercises and guidelines that won't be covered during the DappCon workshop.

