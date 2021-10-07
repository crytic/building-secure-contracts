# Smart contract Fuzzing at scale with Echidna

In this tutorial we will review how we can create a dedicated server for fuzzing smart contracts using Echidna.

### Workflow:

1. Install and setup a dedicated server
2. Start a short fuzzing campaign
3. Start a continuous fuzzing campaign
4. Add properties, check coverage and modify the code if necessary
5. Ending the campaign 

## 1. Install and setup a dedicated server

First, obtain a dedicated server with at least 32 GB of RAM and as many cores as possible. Start creating a user for the fuzzing. 
**Only use the root acount to create an unprivileged user**: 

```
# adduser echidna
# usermod -aG sudo echidna
```

Then, using that user (`echidna`), install some basic dependencies:

```
$ sudo apt install unzip python3-pip
```

Then install everything necessary to build your smart contract as well to run `slither` and `echidna-parade`. For instance:

```
$ pip3 install solc-select
$ solc-select install all
$ pip3 install slither_analyzer
$ pip3 install echidna_parade
```

Add `$PATH=$PATH:/home/echidna/.local/bin` at the end of `/home/echidna/.bashrc`

We should install echidna. The easiest way is to download a precompiled version of echidna, uncompress it and move it to `/home/echidna/.local/bin`:

```
$ wget "https://github.com/crytic/echidna/releases/download/v1.7.2/echidna-test-1.7.2-Ubuntu-18.04.tar.gz"
$ tar -xf echidna-test-1.7.2-Ubuntu-18.04.tar.gz
$ mv echidna-test /home/echidna/.local/bin
```

## 2. Start a short fuzzing campaign

Select a contract to test and provide an initialization if needed. It does not have to be perfect, just start with some basic stuff and iterate over the result.
Before starting this campaign, modify your echidna config to define a corpus directory to use. For instance:

```
corpusDir: "corpus-exploration"
```

This directory will be automatically created but since we are starting a new campaign, **please remove the corpus directory if it was created by previous echidna campaign**. 
If you don't have any properties to test, you can use:

```
benchmarkMode: true
```

to allow echidna to run without any property. 
 
We will start a very short echidna run (5 minutes), to check that everything looks fine. To do that, use the following config:

```
testLimit: 100000000000
timeout: 300 # 5 minutes
```

After it runs, check the coverage file, located in `corpus-exploration/covered.*.txt`. If the initialization is wrong, **clean the `corpus-exploration` directory** and restart the campaign.


## 3. Starting a continuous fuzzing campaign

When you are satisfied with the first iteration of the initialization, we can start a "continuous campaign" for exploration and testing using [echidna-parade](https://github.com/agroce/echidna-parade). Before starting, double check your config file. For instance, if you added properties, do not forget to remove `benchmarkMode`.

echidna-parade is tool is used to launch echidna instances at the same time, keeping track of the corpora of each one. Each instance will be configured to run for a certain amount of time with different parameters in order to maximize the chance to reach new code.

We will show it with an example, where:
* the initial corpus is empty
* the base config file will be exploration.yaml
* the time to run the initial instance will be 3600 seconds (1 hour)
* the time to run each "generations" will be 1800 seconds (30 minutes)
* the campaign will run in continuous mode (if timeout is -1, it means run forever)
* the number of echidna instances per generation will be 8. This should be adjusted according to the number of available cores but avoid using all your cores if you don't want to kill your server
* the target contract is named `C`
* the file that contains the contract is `test.sol`

Finally, we will log the stdout and stderr in `parade.log` and `parade.err` and fork the process to let it run forever. 

```
$ echidna-parade test.sol --config exploration.yaml --initial_time 3600 --gen_time 1800 --timeout -1 --ncores 8 --contract C > parade.log 2> parade.err &
```

**After you run this command, exit the shell so you won't kill it accidentally if your connect fails.**

## 4. Add more properties, check coverage and modify the code if necessary

In this step, we can add more properties while Echidna is exploring the contracts. Keep in mind that you should avoid changing the ABI of the contracts 
(otherwise the quality of the corpus will degrade). 

Also, we can tweak the code to improve coverage, but before starting that, we need to know how to monitor our fuzzing campaign. We can use this command:

```
$ watch "grep 'COLLECTING NEW COVERAGE' parade.log | tail -n 30"
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

you can verify the corresponding covered file, such as `parade.181140/gen.37.6/corpus/covered.1615497368.txt`. 

For examples on how to help echidna to improve its coverage, please review the improving coverage tutorial.

To monitor failed properties, use this command:

```
$ watch "grep 'FAIL' parade.log | tail -n 30"
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

## 4. Ending the campaign

When you are satisfied with the coverage results, you can terminate the continuous campaign using:

```
$ killall echidna-parade echidna
```
