# Installation

Echidna can be installed either through Docker or by using the pre-compiled binary.

## MacOS

To install Echidna on MacOS, simply run the following command:

`brew install echidna`.

## Echidna via Docker

To install Echidna using Docker, execute the following commands:

```bash
docker pull trailofbits/eth-security-toolbox
docker run -it -v "$PWD":/home/training trailofbits/eth-security-toolbox
```

_The last command runs the eth-security-toolbox in a Docker container, which will have access to your current directory. This allows you to modify the files on your host machine and run the tools on those files within the container._

Inside Docker, execute the following commands:

```bash
solc-select use 0.8.0
cd /home/training
```

## Binary

You can find the latest released binary here:

[https://github.com/crytic/echidna/releases/latest](https://github.com/crytic/echidna/releases/latest)

It's essential to use the correct solc version to ensure that these exercises work as expected. We have tested them using version 0.8.0.
