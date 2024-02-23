# Fuzzing Smart Contracts at Scale with Echidna

In this tutorial, we will review how to create a dedicated server for fuzzing smart contracts using Echidna.

### Workflow:

1. Install and set up a dedicated server
2. Begin a short fuzzing campaign
3. Initiate a continuous fuzzing campaign
4. Add properties, check coverage, and modify the code if necessary
5. Conclude the campaign

## 1. Install and set up a dedicated server

First, obtain a dedicated server with at least 32 GB of RAM and as many cores as possible. Start by creating a user for the fuzzing campaign.
**Only use the root account to create an unprivileged user**:

```
# adduser echidna
# usermod -aG sudo echidna
```

Then, using the `echidna` user, install some basic dependencies:

```
sudo apt install unzip python3-pip
```

Next, install everything necessary to build your smart contract(s) as well as `slither` and `echidna-parade`. For example:

```
pip3 install solc-select
solc-select install all
pip3 install slither_analyzer
pip3 install echidna_parade
```

Add `$PATH=$PATH:/home/echidna/.local/bin` at the end of `/home/echidna/.bashrc`.

Afterward, install Echidna. The easiest way is to download the latest precompiled Echidna release, uncompress it, and move it to `/home/echidna/.local/bin`:

```
wget "https://github.com/crytic/echidna/releases/download/v2.0.0/echidna-test-2.0.0-Ubuntu-18.04.tar.gz"
tar -xf echidna-test-2.0.0-Ubuntu-18.04.tar.gz
mv echidna-test /home/echidna/.local/bin
```

## 2. Begin a short fuzzing campaign

Select a contract to test and provide initialization if needed. It does not have to be perfect; begin with some basic items and iterate over the results.
Before starting this campaign, modify your Echidna config to define a corpus directory to use. For instance:

```
corpusDir: "corpus-exploration"
```

This directory will be automatically created, but since we are starting a new campaign, **please remove the corpus directory if it was created by a previous Echidna campaign**.
If you don't have any properties to test, you can use:

```
testMode: exploration
```

to allow Echidna to run without any properties.

We will start a brief Echidna run (5 minutes) to check that everything looks fine. To do that, use the following config:

```
testLimit: 100000000000
timeout: 300 # 5 minutes
```

Once it runs, check the coverage file located in `corpus-exploration/covered.*.txt`. If the initialization is incorrect, **clear the `corpus-exploration` directory** and restart the campaign.

## 3. Initiate a continuous fuzzing campaign

When satisfied with the first iteration of the initialization, we can start a "continuous campaign" for exploration and testing using [echidna-parade](https://github.com/crytic/echidna-parade). Before starting, double-check your config file. For instance, if you added properties, do not forget to remove `benchmarkMode`.

`echidna-parade` is a tool used to launch multiple Echidna instances simultaneously while keeping track of each corpus. Each instance will be configured to run for a specific duration, with different parameters, to maximize the chance of reaching new code.

We will demonstrate this with an example, where:

- the initial corpus is empty
- the base config file is `exploration.yaml`
- the initial instance will run for 3600 seconds (1 hour)
- each "generation" will run for 1800 seconds (30 minutes)
- the campaign will run in continuous mode (if the timeout is -1, it means run indefinitely)
- there will be 8 Echidna instances per generation. Adjust this according to the number of available cores, but avoid using all of your cores if you do not want to overload your server
- the target contract is named `C`
- the file containing the contract is `test.sol`

Finally, we will log the stdout and stderr in `parade.log` and `parade.err` and fork the process to let it run indefinitely.

```
echidna-parade test.sol --config exploration.yaml --initial_time 3600 --gen_time 1800 --timeout -1 --ncores 8 --contract C > parade.log 2> parade.err &
```

**After running this command, exit the shell to avoid accidentally killing it if your connection fails.**

## 4. Add more properties, check coverage, and modify the code if necessary

In this step, we can add more properties while Echidna explores the contracts. Keep in mind that you should avoid changing the contracts' ABI
(otherwise, the quality of the corpus will degrade).

Additionally, we can tweak the code to improve coverage, but before starting, we need to know how to monitor our fuzzing campaign. We can use this command:

```
watch "grep 'COLLECTING NEW COVERAGE' parade.log | tail -n 30"
```

When new coverage is found, you will see something like this:

```
COLLECTING NEW COVERAGE: parade.181140/gen.30.10/corpus/coverage/-3538310549422809236.txt
COLLECTING NEW COVERAGE: parade.181140/gen.35.9/corpus/coverage/5960152130200926175.txt
COLLECTING NEW COVERAGE: parade.181140/gen.35.10/corpus/coverage/3416698846701985227.txt
COLLECTING NEW COVERAGE: parade.181140/gen.36.6/corpus/coverage/-3997334938716772896.txt
COLLECTING NEW COVERAGE: parade.181140/gen.37.7/corpus/coverage/323061126212903141.txt
COLLECTING NEW COVERAGE: parade.181140/gen.37.6/corpus/coverage/6733481703877290093.txt
```

You can verify the corresponding covered file, such as `parade.181140/gen.37.6/corpus/covered.1615497368.txt`.

For examples on how to help Echidna improve its coverage, please review the [improving coverage tutorial](./collecting-a-corpus.md).

To monitor failed properties, use this command:

```
watch "grep 'FAIL' parade.log | tail -n 30"
```

When failed properties are found, you will see something like this:

```
NEW FAILURE: assertion in f: failed!💥
parade.181140/gen.179.0 FAILED
parade.181140/gen.179.3 FAILED
parade.181140/gen.180.2 FAILED
parade.181140/gen.180.4 FAILED
parade.181140/gen.180.3 FAILED
...
```

## 5. Conclude the campaign

When satisfied with the coverage results, you can terminate the continuous campaign using:

```
killall echidna-parade echidna
```
