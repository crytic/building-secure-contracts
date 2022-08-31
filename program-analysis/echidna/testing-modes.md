# How to select the most suitable testing mode

Since Echidna offers several ways to write properties, often developers or auditors are wondering which testing mode should use. We will review how each mode works, as well as their advantages or disadvantages. 

**Table of contents:**
- [Boolean properties](#boolean-properties)
- [Assertions](#assertions)
- [Dapptest](#dapptest)
- [Stateless vs Stateful](#stateless-vs-stateful)

## Boolean properties

By default, the "property" testing mode is used, which reports failures using a special functions called properties:
* Testing functions should be named with a specific prefix (e.g. `echidna_`).
* Testing functions take no parameters, and always return a boolean value.
* Any side effect will be reverted at the end of the execution of the property.
* Properties pass if they return true, and fail if they return false or revert. As an alternative, properties that starts with "echidna_revert_" will fail if they return any value (true or false), and pass if they revert. This pseudo-code summarizes how properties work:

```solidity
function echidna_property() public returns (bool) { // No arguments are required

    // The following statements can trigger a failure if they revert 
    publicFunction(..);
    internalFunction(..);
    contract.function(..);

    // The following statement can trigger a failure depending on the returned value
    return ..;
} // side effects are *not* preserved

function echidna_revert_property() public returns (bool) { // No arguments is required

    // The following statements can *never* trigger a failure
    publicFunction(..);
    internalFunction(..);
    contract.function(..);

    // The following statement will *always* trigger a failure regardless of the value returned
    return ..;
} // side effects are *not* preserved
```

### Advantages:

* Properties can be easier to write and understand compared to other approaches for testing.
* No need to worry about side-effects, since these are reverted at the end of the property execution.

### Disadvantages: 
* Since the properties take no parameters, any additional input should be added using a state variable.
* Any revert will be interpreted as a failure, which is not always expected. 
* No coverage is collected during its execution so these properties should be used with simple code. For anything complex (e.g. with a non-trivial amount of branches), other types of tests should be used.

### Recommendations

This mode can be used when a property can be easily computed from the use of state variables (either internal or public), and there is no need to use extra parameters.

## Assertions 

Using the "assertion" testing mode, Echidna will report an assert violation if:

* The execution reverts during a call to `assert`. Technically speaking, Echidna will detect an assertion failure if it executes an `assert` call that fails in the first call frame of the target contract (so this excludes any internal transactions in most of the cases). 
* An `AssertionFailed` event (with any number of parameters) is emitted by any contract. This pseudo-code summarizes how assertions work:

```solidity
function checkInvariant(..) public { // Any number of arguments is supported

    // The following statements can trigger a failure using `assert`
    assert(..); 
    publicFunction(..);
    internalFunction(..);

    // The following statement will always trigger a failure even if the execution ends with a revert
    emits AssertionFailure(..);

    // The following statement will *only* trigger a failure using `assert` if using solc 0.8.x or newer
    // To make sure it works in older versions, use the AssertionFailure(..) event
    anotherContract.function(..);
    
} // side effects are preserved
```

Functions checking assertions do not require any particular name and are executed like any other function, and therefore, their side effects are kept if they do not revert.

### Advantages

* Easy to implement, in particular, if there are any number of parameters required to compute the invariant.
* Coverage is collected during the execution of these tests, so it can help to reach new failures.
* If the code base already contains assertions for checking invariants, they can be reused.

### Disadvantages

* If the code to test is already using assertions for data validation, it will not work as expected. For example:
```solidity
function deposit(uint256 tokens) public {
  assert(tokens > 0); // should be strictly positive
  ..
```

Developers *should* avoid doing that and use `require` instead, but if that is not possible because you are calling some contract that is outside your control, you can use the `AssertionFailure` event.

### Recommendation

You should use assertions if your invariant is more natural to be expressed using arguments or if it can only be checked in the middle of a transaction. Another good use case of assertions is complex code that require to check something as well as changing the state. In the following example, we test staking of some ERC20, given that there is at least `MINSTAKE` tokens in the sender balance.

```solidity
function testStake(uint256 toStake) public {
    uint256 balance = balanceOf(msg.sender);
    toStake = toStake % (balance + 1); 
    if (toStake < MINSTAKE)                             // Pre: minimal stake is required
      return;
    stake(msg.sender, toStake);                         // Action: token staking
    assert(staked(msg.sender) == toStake);              // Post: staking amount is toStake
    assert(balanceOf(msg.sender) == balance - toStake); // Post: balance decreased
}
```

`testStake` checks some invariants on staking, but also ensures that the state of the contract is properly updated (e.g only allowing a user to stake at least `MINSTAKE`). 

## Dapptest

Using the "dapptest" testing mode, Echidna will report violations using certain functions following how dapptool and foundry work:
* This mode uses any function name with one or more arguments, which will trigger a failure if they revert, except in one special case. This is, if the execution reverts with the special reason “FOUNDRY::ASSUME”, then the test will pass (this emulates how [the `assume` foundry cheat code works](https://github.com/gakonst/foundry/commit/7dcce93a38345f261d92297abf11fafd6a9e7a35#diff-47207bb2f6cf3c4ac054647e851a98a57286fb9bb37321200f91637262d3eabfR90-R96)). This pseudo-code summarizes how dapptests work:

```solidity
function checkDappTest(..) public { // One or more arguments are required
    // The following statements can trigger a failure if they revert
    publicFunction(..);
    internalFunction(..);
    anotherContract.function(..);
    // The following statement will never trigger a failure
    require(.., “FOUNDRY::ASSUME”);
}
```

* Functions implementing these tests do not require any particular name and are executed like any other function, and therefore, their side effects are kept if they do not revert (but usually, this mode is used only in stateless testing).
* The function should NOT be payable (but this can change in the future)

### Advantages:
* Easy to implement, in particular, for stateless mode.
* Coverage is collected during the execution of these tests, so it can help to reach new failures.

### Disadvantages: 
* Almost any revert will be interpreted as a failure, which is not always expected. To avoid this, you should use reverts with `FOUNDRY::ASSUME` or use try/catch.

### Recommendation

Use dapptest mode if you are testing stateless invariants and the code will never unexpectedly revert. Avoid using it for stateful testing, since it was not designed for that (however, Echidna supports it).

## Stateless vs Stateful

Any of these testing modes can be used, in either stateful (by default) or stateless mode (using `--seqLen 1`). In stateful mode, Echidna will keep the state between each function call and will try to break the invariants. In stateless, Echidna will discard the state changes during the fuzzing. There are notable differences in these two modes. 

* Stateful is more powerful, and can allow breaking invariants that exist only if the contract reaches a specific state. 
* Stateless tests can be easier to use than stateful and benefits from simpler input generation.
* Stateless tests can hide issues, since some of them can depend on a sequence of operations that is not reachable in a single transaction. 
* Stateless mode forces resetting the EVM after each transaction or test, which is usually slower than resetting the state once every certain amount of transactions (by default, every 100 transactions).

### Recommendations

In terms of usage for beginners, we recommend starting using Echidna with stateless, and to switch to stateful once you have a good understanding of the system's invariants.
