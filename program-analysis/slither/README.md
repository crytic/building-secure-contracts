# Slither

The aim of this tutorial is to show how to use Slither to automatically find bugs in smart contracts.

- [Installation](#installation)
- [Command line usage](#command-line)
- [Introduction to static analysis](./static_analysis.md): Brief introduction to static analysis
- [API](./api.md): Python API description

Once you feel you understand the material in this README, proceed to the exercises:

- [Exercise 1](./exercise1.md): Function override protection
- [Exercise 2](./exercise2.md): Check for access controls

Watch Slither's [code walkthrough](https://www.youtube.com/watch?v=EUl3UlYSluU) to learn about its code structure.

## Installation

Slither requires Python >= 3.8. It can be installed through pip or using docker.

Slither through pip:

```bash
pip3 install --user slither-analyzer
```

### Docker
Slither through docker:

```bash
docker pull trailofbits/eth-security-toolbox
docker run -it -v "$PWD":/home/trufflecon trailofbits/eth-security-toolbox
```

*The last command runs eth-security-toolbox in a docker that has access to your current directory. You can change the files from your host, and run the tools on the files from the docker*

Inside docker, run:

```bash
solc-select 0.5.11
cd /home/trufflecon/
```

## Command line

**Command line versus user-defined scripts.** Slither comes with a set of predefined detectors that find many common bugs. Calling Slither from the command line will run all the detectors, no detailed knowledge of static analysis needed:

```bash 
slither project_paths
```

In addition to detectors, Slither has code review capabilities through its [printers](https://github.com/crytic/slither#printers) and [tools](https://github.com/crytic/slither#tools).
