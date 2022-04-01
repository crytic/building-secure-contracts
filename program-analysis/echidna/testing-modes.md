# On testing modes and how to use them

Since Echidna offers several ways to write properties, often we are wondering which testing mode we should use. We will review how each mode works, as well as their advantages or disadvantages. 

## Boolean properties

By default, the "property" testing mode is used, which reports failures using a special functions called properties:
* Testing functions should be named with a specific prefix (e.g. `echidna_`).
* Testing functions take no parameters, and always return a boolean value.
* Properties pass if they return true, and fail if they return false or revert. As an alternative, properties that starts with "echidna_revert_" will fail if they return any value (true or false), and pass if they revert. This pseudo-code summarizes how properties work:

```solidity
function echidna_property() public returns (bool) { // No arguments are required

    // The following statements can trigger a failure if they revert 
    publicFunction(..);
    internalFunction(..);
    contract.function(..);

    // The following statement can trigger a failure depending on the returned value
    return ..;
}

function echidna_revert_property() public returns (bool) { // No arguments is required

    // The following statements can *never* trigger a failure
    publicFunction(..);
    internalFunction(..);
    contract.function(..);

    // The following statement will *always* trigger a failure regardless of the value returned
    return ..;
}
```

* Any side effect will be reverted at the end of the execution.

### Advantages:

* Properties can be easier to write and understand.
* No need to worry about side-effects, since these are reverted at the end of the property execution.

### Disadvantages: 
* Since the properties take no parameters, any additional input should be added using a state variable.
* Any revert will be interpreted as a failure, which is not always expected. 
* No coverage is collected during its execution so these properties should be used with simple code. For anything complex (e.g. with a non-trivial amount of branches), other types of tests should be used.

### Recommendations

This mode can be used when a property can be computed from the use of state variables (either internal or public), and there is no need to use extra parameters.
