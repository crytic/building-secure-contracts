# Using optimization mode to find local maximums

**Table of contents:**

- [Using optimization mode to find local maximums](#using-optimization-mode-to-find-local-maximums)
  - [Introduction](#introduction)
  - [Optimizing with Echidna](#optimizing-with-echidna)

## Introduction

We will see how to perform function optimization using Echidna. This tutorial will require Echidna 2.0.5 or greater,
so make sure you have update it before starting.

Optimization mode is a experimental feature that allows to define a special function which takes no arguments
and returns a `int256`. Echidna will try find a sequence of transactions to maximize the value returned:

```solidity
function echidna_opt_function() public view returns (int256) {
    // if it reverts, Echidna will assumed it returned type(int256).min
    return ...;
}
```

## Optimizing with Echidna

In this example, the target is the following smart contract (_[../example/opt.sol](../example/opt.sol)_):

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

This small example forces Echidna to maximize certain price difference given some preconditions. If the preconditions are not
met, the function will revert, without changing the actual value.

To run this example:

```
echidna-test opt.sol --test-mode optimization --test-limit 100000 --seq-len 1 --corpus-dir corpus --shrink-limit 50000
...
echidna_opt_price_difference: max value: 1076841

  Call sequence, shrinking (42912/50000):
    setMaxPriceDifference(1349752405,1155321,609,1524172858) Time delay: 603902 seconds Block delay: 21

```

The resulting max value is not unique, running in longer campaign will likely result in a larger value.

Regarding the command line, the optimization mode is enabled using `--test-mode optimization`. additionally, we included the following tweaks:

1. Use only one transaction (we know that the function is stateless)
2. Use a large shrink limit in order to obtain a better value during the minimization of the complexity of the input.

Every time Echidna is executed using the corpus directory, the last input that produces the maximum value should be re-used from the `reproducers` directory:

```
echidna-test opt.sol --test-mode optimization --test-limit 100000 --seq-len 1 --corpus-dir corpus --shrink-limit 50000
Loaded total of 1 transactions from corpus/reproducers/
Loaded total of 9 transactions from corpus/coverage/
Analyzing contract: /home/g/Code/echidna/opt.sol:TestDutchAuctionOptimization
echidna_opt_price_difference: max value: 1146878

  Call sequence:
    setMaxPriceDifference(1538793592,1155321,609,1524172858) Time delay: 523701 seconds Block delay: 49387
```
