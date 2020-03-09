In this short tutorial, we are going to show how to use Echidna to test assertion checking in contracts. Let's suppose we have a contract like this one: 

```solidity
contract Incrementor {
  uint private counter = 2**200;

  function inc(uint val) public returns (uint){
    uint tmp = counter;
    counter += val;
    // tmp <= counter
    return (counter - tmp);
  }
}
```

We want to make sure that `tmp` is less or equal than `counter` after returning its difference. We could write an 
Echidna property, but we will need to store the `tmp` value somewhere. Instead, we could use an assertion like this one:

```solidity
contract Incrementor {
  uint private counter = 2**200;

  function inc(uint val) public returns (uint){
    uint tmp = counter;
    counter += val;
    assert (tmp <= counter);
    return (counter - tmp);
  }
}
```
    
Echidna is capable of testing assertion failure, only if you enable the `checkAssert` configuration option:

```yaml
checkAsserts: true
```

When we run this contract in Echidna, we obtain the expected results:

```
$ echidna-test assert.sol --config assert.yaml 
Analyzing contract: assert.sol:Incrementor
assertion in inc: failed!💥  
  Call sequence, shrinking (2596/5000):
    inc(21711016731996786641919559689128982722488122124807605757398297001483711807488)
    inc(7237005577332262213973186563042994240829374041602535252466099000494570602496)
    inc(86844066927987146567678238756515930889952488499230423029593188005934847229952)

Seed: 1806480648350826486
```

As you can see, Echidna reports some assertion failure in the `inc` function. Adding more than one assertion per function is possible, but Echidna cannot tell which assertion failed.

In general, we recommend following [John Regehr's recommendation](https://blog.regehr.org/archives/1091) on how to use assertions:

* Do not force any side effect during the assertion checking. For instance: `assert(ChangeStateAndReturn() == 1)`
* Do not assert obvious statements. For instance `assert(var >= 0)` where `var` is declared as `uint`.

Finally, please **do not use** `require` instead of `assert`, since Echidna will not be able to detect it (but the contract will revert anyway).
