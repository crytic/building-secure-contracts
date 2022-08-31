# Common testing approaches

Testing of smart contracts is not as straightforward as testing normal binaries that you run in your local computer. 
This is caused by the existence of multiple accounts interacting with one or many entry points. 
While a fuzzer can simulate the Ethereum Virtual Machine and can potentially use any account with any feature (e.g. a an unlimited amount of ETH), 
we take care to avoid breaking some important underlying assumptions of transactions that are impossible in Ethereum (e.g. for instance using msg.sender as the zero address). 
That is why it is important to have a clear view of the system to test, and how transactions are going to be simulated. There are a few classifications for the testing approach. 
We will start by two them, internal or external:

**Table of contents:**
- [Common testing approaches](#common-testing-approaches)
  - [Internal testing](#internal-testing)
  - [External testing](#external-testing)
  - [Partial testing](#partial-testing)

## Internal testing
In this testing approach, properties are defined inside the contract to test, with complete access to the internal state of the system.

```solidity
Contract InternalTest is System { 
    function echidna_state_greater_than_X() public returns (bool) {
       return stateVar > X;
    }
}
```

In this approach, Echidna generate will transactions from a simulated account to the target contract. This testing approach is particularly useful for simpler contracts that do not require a complex initialization and have a single entrypoint. 
Additionally, properties can be easier to write, since properties can access the system's internal state.
 
## External testing
In the external testing approach, properties are tested using external calls from a different contract. Properties are only allowed to access external/public variables or functions.  

```solidity
contract ExternalTest {
    constructor() public {
       addr = address(0x...);
    }
    function echidna_state_greater_than_X() public returns (bool) {
       return System(addr).stateVar() > X;
    }
}
```

This testing approach is useful for dealing with contracts that require external initialization (e.g. using Etheno), however, it should handle correctly how Echidna runs the transactions, 
since the contract with the properties is no longer the same as the one we want to test. 
Since `ExternalTest` defines no additional methods, running Echidna directly on this will not allow any code to be executed from the contract to test (there are no functions in `ExternalTest` to call besides the actual properties). 
In this case, there are several alternatives:

**Contract wrapper**: define specific operations to "wrap" the system to test. For every operation that we want Echidna to execute in the system to test, 
we add one or more functions that performs external to it.

```solidity
contract ExternalTest {
    constructor() public {
       addr = ..;
    }

    function method(...) public returns (...) {
       return System(addr).method(..);
    }

    function echidna_state_greater_than_X() public returns (bool) {
       return System(addr).stateVar() > X;
    }
}
```

There are two important points to consider in this approach:
* The sender of each transaction will be the `ExternalTest` contract, instead of the simulated Echidna senders (e.g `0x10000`, ..). This means that the real address  interacting with the system will be the `External` contract one, instead of one of the Echidna senders. Please take particular care, if you need  to provide ETH or tokens into this contract. 

* This approach is manual and can be time consuming if there a lot of functions operations, 
but it can be useful when Echidna needs some help calculating some value which cannot be randomly sampled:
 
```solidity
contract ExternalTest {
    ...
    function methodUsingF(..., uint256 x) public returns (...) {
       return System(addr).method(.., f(x));
    }
    ... 
}
```

**Multi ABI**: Echidna is capable of performing direct calls to every contract, if the `multi-abi` mode is enabled. 
This means that using it wil not require wrapped calls, however since every contract deployed can be called, there could be unintended effects. 
For instance, if we have a property to ensure that the amount of tokens is limited:

```solidity
contract ExternalTest {
    constructor() public {
       addr = ..;
       MockERC20(..).mint(..);  
    }

    function echidna_limited_supply() public returns (bool) {
       return System(addr).balanceOf(...) <= X;
    }
    ... 
}
``` 

If we used "mock" contracts for tokens (e.g. MockERC20)  could be an issue, because Echidna could call functions that are public but are only supposed to be used during the initialization such as `mint`. This can be easily solved using a blacklist of functions to ignore:

```yaml
filterBlacklist: true
filterFunctions: [“MockERC20.mint(uint256,address)”]
```

Finally, there is another benefit for using this approach: it will force the developer or auditor to write properties using public data. 
If an important property cannot be defined using public data, it could be an indication that users or other contracts will NOT be able to easily interact with the system to either perform some operation or verify that the system is in a valid state.

## Partial testing

Ideally, testing a smart contract system uses the complete deployed system, with the same parameters that the developers intend to use. 
Testing with the real code, it is always preferred, even if it is slower than doing something else (but perhaps not in the case that it is extremely slow). 
However, there are many cases where even if the complete system is deployed, it cannot be simulated because it depends on off-chain 
components (e.g. a token bridge). In such cases, we are forced to implement alternative solutions.  

In this case, we will do testing of some of the components, ignoring or abstracting uninteresting parts such as standard ERC20 tokens or oracles. 
There are a few ways to do this. 

**Isolated testing**: If a component is properly abstracted from the rest of the system, testing it can be easy. 
This is particularly useful for testing stateless properties that you can find in components that compute mathematical operations, such as 
mathematical libraries.

**Function override**: Solidity allows to override functions, in order to change the functionality of a piece of code, without affecting the rest of the code base. We can use this to disable certain functions in our tests, in order to allow testing using Echidna:

```solidity
Contract InternalTestOverridingSignatures is System {

    function verifySignature(..) public returns (bool) override {
      return true; // signatures are always valid
    }
 
    function echidna_state_greater_than_X() public returns (bool) {
       executeSomethingWithSignature(..)
       return stateVar > X;
    }
}
```

**Model testing**: if the system is not modular enough, then we will need a different approach. 
Instead of using the code as it is, we will create a “model” of the system in Solidity, using mostly the original code. While there is no defined list of steps to build a model, we can show a generic example. Let’s assume we have a complex system that include this piece of code:

```solidity
Contract System {
    … 
    function calculateSomething() public returns (uint256) {
       if (booleanState) {
           stateSomething = (uint256State1 * uint256State2) / 2**128;
           return stateSomething / uint128State;
       } 
       …
    }
}
```

Where `boolState`, `uint256State1`, `uint256State2` and `stateSomething` are state variables of our system to test. 
We are going to create a model (e.g. copy, paste and modify the original code in a new contract), where each state variable is 
transformed into a parameter:

```solidity
Contract SystemModel {

    function calculateSomething(bool boolState, uint256 uint256State1, …) public returns (uint256) {
       if (boolState) {
           stateSomething = (uint256State1 * uint256State2) / 2**128;
           return stateSomething / uint128State;
       } 
       …
    }
}
```

At this point, we should be able to compile our model without any dependency from the original codebase (everything necessary should be included in 
the model). Then, we can insert assertions to detect when the returned value exceeds a certain threshold.

While developers or auditors can be tempted to quickly create tests using this technique there are certain disadvantages when creating models:

* The code tested can be very different from the one we want to test: this can either introduce issues that are not real (false positives) or 
hide real issues from the original code (false negatives). In the example, it is unclear if the state variable can take arbitrary values.

* The model will have a limited value if the code is changed since any modification in the original model will force a rebuild of the model, 
and this should be manually performed.

In any case, developers should be warned that their code is difficult to test and it should be refactored to avoid this issue in the future.
