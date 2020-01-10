# Slither

The aim of this tutorial is to show how to use Slither to automatically find bugs in smart contracts.


**Table of contents:**

- [Installation](#installation)
- [Command line usage](#command-line)
- [Introduction to static analysis](./static-analysis-introduction.md): Brief introduction to static analysis
- [API](./api.md): Slither Python's API description
- [Exercise 1](./exercise1.md): Function overridden protection
- [Exercise 2](./exercise2.md): Access control check

## Installation

Slither requires python >= 3.6. It can be installed through pip or using docker.

### Slither through pip

```bash
pip3 install --user slither-analyzer
```

### Slither through docker

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

### Running a script

To run a python script with python 3:

```bash
python3 script.py
```

## Command line

**Command line versus user-defined scripts.** Slither comes with a set of predefined detectors that will find the most-frequent bugs. Calling Slither from the command line will run all the detectors and will necessitate no user configuration or knowledge in static analysis:

```bash 
slither project_paths
```

In addition to detectors, Slither has code review capabilities through its [printers](https://github.com/crytic/slither#printers) and [tools](https://github.com/crytic/slither#tools).

Use [crytic.io](https://crytic.io) to get access to private detectors and GitHub integration.
