# Fuzzing Tips

The following describe fuzzing tips to make Echidna more efficient:

- **To filter the values range of inputs, use `%`**. See [Filtering inputs](#filtering-inputs).
- **When dynamic arrays are needed, use push/pop**. See [Dealing with dynamic arrays](#dealing-with-dynamic-arrays).

## Filtering inputs

To filter inputs, `%` is more efficient than adding `require` or `if` statements. For example, if you are a fuzzing a `operation(uint256 index, ..)` where `index` is supposed to be less than `10**18`, use:

```solidity
function operation(uint256 index) public {
    index = index % 10 ** 18;
    // ...
}
```

If `require(index <= 10**18)` is used instead, many transactions generated will revert, slowing the fuzzer.

This can also be generalized define a min and max range, for example:

```solidity
function operation(uint256 balance) public {
    balance = MIN_BALANCE + (balance % (MAX_BALANCE - MIN_BALANCE));
    // ...
}
```

Will ensure that `balance` is always between `MIN_BALANCE` and `MAX_BALANCE`, without discarding any generated transactions. As expected, this will speed up the exploration, but at the cost of avoiding certain paths in your code. To overcome this issue, the usual solution is to have two functions:

```solidity
function operation(uint256 balance) public {
    // ...
}

function safeOperation(uint256 balance) public {
    balance = MIN_BALANCE + (balance % (MAX_BALANCE - MIN_BALANCE)); // safe balance
    // ...
}
```

So Echidna is free to use any of these, exploring safe and unsafe usage of the input data.

# Dealing with dynamic arrays

When a dynamic array is used as input, Echidna will limit the size of it to 32 elements:

```solidity
function operation(uint256[] calldata data) public {
    // ...
}
```

This is because deserializing dynamic arrays is slow and can take some amount of memory during the execution. Dynamic arrays are also problematic since they are hard to mutate. Despite this, Echidna includes some specific mutators to remove/repeat elements or cut elements. These mutators are performed using the collected corpus. In general, we suggest the use of `push(...)` and `pop()` functions to handle the exploration of dynamic arrays used as inputs:

```solidity
contract DataHandler {
    uint256[] data;

    function push(uint256 x) public {
        data.push(x);
    }

    function pop() public {
        data.pop();
    }

    function operation() public {
        // Use of `data`
    }
}
```

This will work well to test arrays with a small amount of elements; however, it introduces an unexpected bias in the exploration: since `push` an `pop` are functions that will be selected with equal probability, the chance of building large arrays (e.g. more than 64 elements) is very very small. One quick solution could be to blacklist the `pop()` function during a short campaign:

```
filterFunctions: ["C.pop()"]
```

This is enough for small scale testing. A more general solution is available using a specific testing technique called [_swarm testing_](https://www.cs.utah.edu/~regehr/papers/swarm12.pdf). This allows to run a long testing campaign with some tool but randomly shuffling the configuration of it. In case of Echidna, swarm testing runs with different config files, where it blacklists some number of random functions from the contract before testing. We offer swarm testing and scalability with [echidna-parade](https://github.com/crytic/echidna-parade), our dedicated tool for fuzzing smart contracts. A specific tutorial in the use of echidna-parade is available [here](./advanced/smart-contract-fuzzing-at-scale.md).
