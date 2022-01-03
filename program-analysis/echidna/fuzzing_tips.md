# Fuzzing Tips

The following describe fuzzing tips to make Echidna more efficient:

- **To filter the values range of inputs, use `%`**. See [Filtering inputs](#filtering_inputs).
- **When dynamic arrays are needed, use push/pop**. See [Dealing with dynamic arrays](#dealing_with_dynamic_arrays).

## Filtering inputs

To filter inputs, `%` is more efficient than adding `require` or `if` statements. For example, if you are a fuzzing a `operation(uint256 index, ..)` where `index` is supposed to be less than `10**18`, use:

```solidity
function operation(uint index, ...) public{
   index = index % 10**18
   ...
}
```

If `require(index <= 10**18)` is used instead, many transactions generated will revert, slowling the fuzzer. 

This can also be generalized define a min and max range, for example:


```solidity
function operation(uint balance, ...) public{
   balance = MIN_BALANCE + balance % (MAX_BALANCE - MIN_BALANCE);
   ...
}
```

Will ensure that `balance` is always between `MIN_BALANCE` and `MAX_BALANCE`, without discarding any generated transactions. As expected, this will speed up the exploration, but at the cost of avoiding certain path in your code. To overcome this issue, the usual solution is to have two functions:

```solidity
function operation(uint balance, ...) public{
   ... // original code
}

function safeOperation(uint balance, ...) public{
   balance = MIN_BALANCE + balance % (MAX_BALANCE - MIN_BALANCE); // safe balance
   ...
}
```

So Echidna is free to use any of these, exploring safe and usafe usage of the input data.

# Dealing with dynamic arrays

When a dynamic array is used as input, Echidna will limit the size of it to 32 elements:

```solidity
function operation(uint256[] data, ...) public{
   ... // use of data
}
```

This is because deserializing dynamic array is slow and can take a some amount of memory during the execution. Dynamic arrays are also problematic since they are hard to mutate. Despite Echidna includes some specific mutators (to remove/repeat elements or cut them), the mutators are performed using the collected corpus. That is why we suggest to use an functions `push(..)` and `pop()` to handle the exporation of dynamic array used as inputs:

```solidity
private uint256[] data;
function push(uint256 x) public{
   data.push(x);
}

function pop() public{
   data.pop();
}

function operation(...) public{
   ... // use of data
}
```

This will work well to test arrays with a small amount of elements, however, it introduces an unexpected bias in the exploration: since `push` an `pop` are functions that will be selected with equal probability, the chance of builiding large arrays (e.g. more than 64 elements) is very very small. One quick solution could be to run Echidna blacklisting the `pop()` during a short campaign:

```
filterFunctions: ["C.pop()"]
```

This is enough for small scale testing. A more general solution is available using a specific testing technique called [*swarm testing*](https://www.cs.utah.edu/~regehr/papers/swarm12.pdf). This allows to run a long testing campaign with some tool but randomly shuffling the configuration of it. In case of Echidna, swarm testing runs with different config files, where it blacklists an amount of random functions from the contract to test. We offer swarm testing and scalability with [echidna-parade](https://github.com/crytic/echidna-parade), our dedicated tool for fuzzing smart contracts. A specific tutorial in the use of echidna-parade is available [here](smart-contract-fuzzing-at-scale.md).
