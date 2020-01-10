# Manticore Tutorial

The aim of this tutorial is to show how to use Manticore to automatically find bugs in smart contracts.

The first part introduces a set of the basic features of Manticore: running under Manticore and manipulating smart contracts through API, getting throwing path, adding constraints.
The second part is exercise to solve.

**Table of contents:**

- [Installation](#installation)
- [Introduction to symbolic execution](./symbolic-execution-introduction.md): Brief introduction to symbolic execution
- [Running under Manticore](./running-under-manticore.md): How to use Manticore's API to run a contract
- [Getting throwing paths](./getting-throwing-paths.md): How to use Manticore's API to get specific paths
- [Adding constraints](./adding-constraints.md): How to use Manticore's API to add paths' constraints
- [Exercises](./exercises)

Join the team on Slack at: https://empireslacking.herokuapp.com/ #ethereum, #manticore

## Installation

Manticore requires >= python 3.6. It can be installed through pip or using docker.

## Manticore through docker

```bash
docker pull trailofbits/eth-security-toolbox
docker run -it -v "$PWD":/home/training trailofbits/eth-security-toolbox
```

*The last command runs eth-security-toolbox in a docker that has access to your current directory. You can change the files from your host, and run the tools on the files from the docker*

Inside docker, run:

```bash
solc-select 0.5.11
cd /home/trufflecon/
```

### Manticore through pip

```bash
pip3 install --user manticore
```

solc 0.5.11 is recommended.

### Running a script

To run a python script with python 3:

```bash
python3 script.py
```
