# Manticore Tutorial

This tutorial demonstrates how to use Manticore to automatically find bugs in smart contracts.

The first part introduces a set of Manticore's basic features, including running Manticore, manipulating smart contracts through the API, retrieving throwing paths, and adding constraints. The second part consists of exercises to solve.

**Table of contents:**

- [Installation](#installation)
- [Introduction to symbolic execution](./symbolic-execution-introduction.md): A brief introduction to symbolic execution
- [Running Manticore](./running-under-manticore.md): Using Manticore's API to run a contract
- [Getting throwing paths](./getting-throwing-paths.md): Using Manticore's API to obtain specific paths
- [Adding constraints](./adding-constraints.md): Using Manticore's API to add path constraints
- [Exercises](./exercises)

Join the team on Slack at: https://empireslacking.herokuapp.com/ #ethereum, #manticore

## Installation

Manticore requires Python 3.6 or later. It can be installed using pip or Docker.

## Manticore through Docker

```bash
docker pull trailofbits/eth-security-toolbox
docker run -it -v "$PWD":/home/training trailofbits/eth-security-toolbox
```

_The last command runs the eth-security-toolbox in a Docker container with access to your current directory. You can modify the files on your host and run the tools on the files from the Docker container._

Inside the Docker container, run:

```bash
solc-select 0.5.11
cd /home/trufflecon/
```

### Manticore through pip

```bash
pip3 install --user manticore
```

It is recommended to use solc 0.5.11.

### Running a script

To run a Python script with Python 3:

```bash
python3 script.py
```
