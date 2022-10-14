# Building Secure Smart Contracts - Devcon Edition

The slides are [here](https://github.com/crytic/building-secure-contracts/blob/devcon/Josselin%20Feist%2C%20Gustavo%20Grieco%20-%20Building%20Secure%20Contracts_%20Use%20Echidna%20Like%20a%20Pro.pdf).

## Install Echidna
- On MacOs: `brew install echidna`
- On other systems: download from https://github.com/crytic/echidna/releases/tag/v2.0.3

Consider using [eth-security-toolbox](https://github.com/trailofbits/eth-security-toolbox/) (docker) if you have troubles running Echidna.

## Exercises
- [Exercise 1](program-analysis/echidna/Exercise-1.md)
- [Exercise 2](program-analysis/echidna/Exercise-2.md)
- [Exercise 4](program-analysis/echidna/Exercise-4.md)
- [Exercise 5](program-analysis/echidna/Exercise-5.md)
- [Exercise 6](program-analysis/echidna/Exercise-6.md)

## Additional information
Consider using [solc-select](https://github.com/crytic/solc-select) to easily switch Solidity versions:
- `pip3 install solc-select`: to install it
- `solc-select install 0.7.0`: to install solc `0.7.0`
- `solc-select use 0.7.0`: to switch to solc `0.7.0`

[Building-secure-contracts](https://github.com/crytic/building-secure-contracts) contains additional exercises and guidelines that won't be covered during the Devcon workshop.

