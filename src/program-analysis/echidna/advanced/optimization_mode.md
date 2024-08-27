# Finding Local Maximums Using Optimization Mode

**Table of Contents:**

- [Finding Local Maximums Using Optimization Mode](#finding-local-maximums-using-optimization-mode)
  - [Introduction](#introduction)
  - [Optimizing with Echidna](#optimizing-with-echidna)

## Introduction

In this tutorial, we will explore how to perform function optimization using Echidna. Please ensure you have updated Echidna to version 2.0.5 or greater before proceeding.

Optimization mode is an experimental feature that enables the definition of a special function, taking no arguments and returning an `int256`. Echidna will attempt to find a sequence of transactions to maximize the value returned:

```solidity
function echidna_opt_function() public view returns (int256) {
    // If it reverts, Echidna will assume it returned type(int256).min
    return value;
}
```

## Optimizing with Echidna

In this example, the target is the following smart contract ([opt.sol](https://github.com/crytic/building-secure-contracts/blob/master/program-analysis/echidna/example/opt.sol)):

```solidity
contract TestDutchAuctionOptimization {
    int256 maxPriceDifference;

    function setMaxPriceDifference(uint256 startPrice, uint256 endPrice, uint256 startTime, uint256 endTime) public {
        if (endTime < (startTime + 900)) revert();
        if (startPrice <= endPrice) revert();

        uint256 numerator = (startPrice - endPrice) * (block.timestamp - startTime);
        uint256 denominator = endTime - startTime;
        uint256 stepDecrease = numerator / denominator;
        uint256 currentAuctionPrice = startPrice - stepDecrease;

        if (currentAuctionPrice < endPrice) {
            maxPriceDifference = int256(endPrice - currentAuctionPrice);
        }
        if (currentAuctionPrice > startPrice) {
            maxPriceDifference = int256(currentAuctionPrice - startPrice);
        }
    }

    function echidna_opt_price_difference() public view returns (int256) {
        return maxPriceDifference;
    }
}
```

This small example directs Echidna to maximize a specific price difference given certain preconditions. If the preconditions are not met, the function will revert without changing the actual value.

To run this example:

```
echidna opt.sol --test-mode optimization --test-limit 100000 --seq-len 1 --corpus-dir corpus --shrink-limit 50000
...
echidna_opt_price_difference: max value: 1076841

  Call sequence, shrinking (42912/50000):
    setMaxPriceDifference(1349752405,1155321,609,1524172858) Time delay: 603902 seconds Block delay: 21

```

The resulting max value is not unique; running a longer campaign will likely yield a larger value.

Regarding the command line, optimization mode is enabled using `--test-mode optimization`. Additionally, we included the following tweaks:

1. Use only one transaction (as we know the function is stateless).
2. Use a large shrink limit to obtain a better value during input complexity minimization.

Each time Echidna is executed using the corpus directory, the last input producing the maximum value should be reused from the `reproducers` directory:

```
echidna opt.sol --test-mode optimization --test-limit 100000 --seq-len 1 --corpus-dir corpus --shrink-limit 50000
Loaded total of 1 transactions from corpus/reproducers/
Loaded total of 9 transactions from corpus/coverage/
Analyzing contract: /home/g/Code/echidna/opt.sol:TestDutchAuctionOptimization
echidna_opt_price_difference: max value: 1146878

  Call sequence:
    setMaxPriceDifference(1538793592,1155321,609,1524172858) Time delay: 523701 seconds Block delay: 49387
```
