# Fuzzing Tips

The following tips will help enhance the efficiency of Echidna when fuzzing:

- **Use `%` to filter the range of input values**. Refer to [Filtering inputs](#filtering-inputs) for more information.
- **Use push/pop when dealing with dynamic arrays**. See [Handling dynamic arrays](#handling-dynamic-arrays) for details.

## Filtering Inputs

Using `%` is more efficient for filtering input values than adding `require` or `if` statements. For instance, when fuzzing an `operation(uint256 index, ..)` with `index` expected to be less than `10**18`, use the following:

```solidity
function operation(uint256 index) public {
    index = index % 10 ** 18;
    // ...
}
```

Using `require(index <= 10**18)` instead would result in many generated transactions reverting, which would slow down the fuzzer.

To define a minimum and maximum range, you can adapt the code like this:

```solidity
function operation(uint256 balance) public {
    balance = MIN_BALANCE + (balance % (MAX_BALANCE - MIN_BALANCE));
    // ...
}
```

This ensures that the `balance` value stays between `MIN_BALANCE` and `MAX_BALANCE`, without discarding any generated transactions. While this speeds up the exploration process, it might prevent some code paths from being tested. To address this issue, you can provide two functions:

```solidity
function operation(uint256 balance) public {
    // ...
}

function safeOperation(uint256 balance) public {
    balance = MIN_BALANCE + (balance % (MAX_BALANCE - MIN_BALANCE)); // safe balance
    // ...
}
```

Echidna can then use either of these functions, allowing it to explore both safe and unsafe usage of the input data.

## Handling Dynamic Arrays

When using a dynamic array as input, Echidna restricts its size to 32 elements:

```solidity
function operation(uint256[] calldata data) public {
    // ...
}
```

This is because deserializing dynamic arrays can be slow and may consume a significant amount of memory. Additionally, dynamic arrays can be difficult to mutate. However, Echidna includes specific mutators to remove/repeat elements or truncate elements, which it performs using the collected corpus. Generally, we recommend using `push(...)` and `pop()` functions to handle dynamic arrays used as inputs:

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

This approach works well for testing arrays with a small number of elements. However, it can introduce an exploration bias: since `push` and `pop` functions are selected with equal probability, the chances of creating large arrays (e.g., more than 64 elements) are very low. One workaround is to blacklist the `pop()` function during a brief campaign:

```
filterFunctions: ["C.pop()"]
```

This should suffice for small-scale testing. A more comprehensive solution involves [_swarm testing_](https://www.cs.utah.edu/~regehr/papers/swarm12.pdf), a technique that performs long testing campaigns with randomized configurations. In the context of Echidna, swarm testing is executed using different configuration files, which blacklist random contract functions before testing. We offer swarm testing and scalability through [echidna-parade](https://github.com/crytic/echidna-parade), our dedicated tool for fuzzing smart contracts. A tutorial on using echidna-parade can be found [here](./advanced/smart-contract-fuzzing-at-scale.md).
