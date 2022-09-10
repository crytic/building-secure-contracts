# Building Secure Smart Contracts - DappCon Edition

- Install Echidna: download from https://github.com/crytic/echidna/releases/tag/v2.0.3
  - If MacOS is complaining about unverified app, you can authorize echidna with: `sudo xattr -r -d com.apple.quarantine path/to/your/echidna/folder`
- [Exercise 1](program-analysis/echidna/Exercise-1.md)
- [Exercise 2](program-analysis/echidna/Exercise-2.md)

Consider using [solc-select](https://github.com/crytic/solc-select) to easily switch Solidity version. Consider using [eth-security-toolbox](https://github.com/trailofbits/eth-security-toolbox/) (docker) if you have troubles running Echidna.

[Building-secure-contracts](https://github.com/crytic/building-secure-contracts) contains additional exercises and guidelines that won't be covered during the DappCon workshop.

