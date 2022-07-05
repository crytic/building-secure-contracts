# Slither Tutorial

The aim of this tutorial is to show how to use Slither to automatically find
bugs in smart contracts.

## Table of Contents

- Introduction
  - [Installation](#installation)
  - [Introduction to static analysis: A brief introduction to static analysis](./static-analysis.md)
  - [API highlights: An overview of commonly used methods and attributes from the Slither API](./api-overview.md)
    [![Binder](https://mybinder.org/badge_logo.svg)](https://mybinder.org/v2/gh/crytic/building-secure-contracts/rgs/slither-jupyter?labpath=program-analysis%2Fslither%2Fjupyter%2FAPI.ipynb)
- Basics
  - [Running Slither detectors on smart contracts](./running-detectors.md)
    [![Binder](https://mybinder.org/badge_logo.svg)](https://mybinder.org/v2/gh/crytic/building-secure-contracts/rgs/slither-jupyter?labpath=program-analysis%2Fslither%2Fjupyter%2FDetectors.ipynb)
  - [Running Slither printers on smart contracts](./running-printers.md)
    [![Binder](https://mybinder.org/badge_logo.svg)](https://mybinder.org/v2/gh/crytic/building-secure-contracts/rgs/slither-jupyter?labpath=program-analysis%2Fslither%2Fjupyter%2FPrinters.ipynb)
  - [Using a Slither utility on smart contracts](./running-utils.md)
  - [Troubleshooting & FAQs](./faq.md)
- Advanced
  - [How to build a custom Slither detector](./building-detectors.md)
  - [How to build a custom Slither printer](./building-printers.md)
- Exercises
  - [Exercise 1](./exercise1.md)
  - [Exercise 2](./exercise2.md)

## Installation

Slither requires Python >= 3.6. It can be installed through pip or by using
docker.

Slither through pip:

```bash
pip3 install --user slither-analyzer
```

Slither through docker:

```bash
docker pull trailofbits/eth-security-toolbox
docker run -it -v "$PWD":/home/trufflecon trailofbits/eth-security-toolbox
```

_The last command runs eth-security-toolbox in a docker that has access to your
current directory. You can change the files from your host, and run the tools on
the files from the docker_

Inside docker, run:

```bash
solc-select 0.5.11
cd /home/trufflecon/
```
