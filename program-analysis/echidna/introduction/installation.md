# Installation

Echidna can be installed through docker or using the pre-compiled binary.

## MacOS

You can install Echidna with `brew install echidna`.

## Echidna through docker

```bash
docker pull trailofbits/eth-security-toolbox
docker run -it -v "$PWD":/home/training trailofbits/eth-security-toolbox
```

_The last command runs eth-security-toolbox in a docker container that has access to your current directory. You can change the files from your host and run the tools on the files through the container_

Inside docker, run :

```bash
solc-select use 0.5.11
cd /home/training
```

## Binary

Check for the lastest released binary here:

[https://github.com/crytic/echidna/releases/latest](https://github.com/crytic/echidna/releases/latest)

The solc version is important to ensure that these exercises work as expected, we tested them using version 0.5.11.
