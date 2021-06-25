# How to test bytecode only contracts

**Table of contents:**
- [Introduction](#introduction)
- [Proxy pattern](#proxy-pattern)
- [Run Echidna](#run-echidna)
- [Differential fuzzing](#differential-fuzzing)
- [Generic proxy pattern](#generic-proxy-pattern)
- [Summary: Testing bytecode](#summary-testing-bytecode)

## Introduction

We will see how to fuzz a contract without providing the source code. 
The technique can used to do differential fuzzing (i.e. compare multiple implementations) between a Solidity contract, and a Vyper contract, or without source code.

Consider the following bytecode:
```
608060405234801561001057600080fd5b506103e86000803373ffffffffffffffffffffffffffffffffffffffff1673ffffffffffffffffffffffffffffffffffffffff168152602001908152602001600020819055506103e86001819055506101fa8061006e6000396000f3fe608060405234801561001057600080fd5b50600436106100415760003560e01c806318160ddd1461004657806370a0823114610064578063a9059cbb146100bc575b600080fd5b61004e61010a565b6040518082815260200191505060405180910390f35b6100a66004803603602081101561007a57600080fd5b81019080803573ffffffffffffffffffffffffffffffffffffffff169060200190929190505050610110565b6040518082815260200191505060405180910390f35b610108600480360360408110156100d257600080fd5b81019080803573ffffffffffffffffffffffffffffffffffffffff16906020019092919080359060200190929190505050610128565b005b60015481565b60006020528060005260406000206000915090505481565b806000803373ffffffffffffffffffffffffffffffffffffffff1673ffffffffffffffffffffffffffffffffffffffff16815260200190815260200160002060008282540392505081905550806000808473ffffffffffffffffffffffffffffffffffffffff1673ffffffffffffffffffffffffffffffffffffffff16815260200190815260200160002060008282540192505081905550505056fe
```

For which we only know the ABI:
```solidity
interface Target{
  function totalSupply() external returns(uint);
  function balanceOf(address) external returns(uint);
  function transfer(address, uint) external;
}
```

We want to test if it is possible to have more tokens than the total supply.


## Proxy pattern
Because we don't have the source code, we cannot directly add the property in the contract.
Instead we will use a proxy contract:

```solidity
interface Target{
  function totalSupply() external returns(uint);
  function balanceOf(address) external returns(uint);
  function transfer(address, uint) external;
}

contract TestBytecodeOnly{
    Target t;

    constructor() public{
        address target_addr;
        // init bytecode
        bytes memory target_bytecode = hex"608060405234801561001057600080fd5b506103e86000803373ffffffffffffffffffffffffffffffffffffffff1673ffffffffffffffffffffffffffffffffffffffff168152602001908152602001600020819055506103e86001819055506101fa8061006e6000396000f3fe608060405234801561001057600080fd5b50600436106100415760003560e01c806318160ddd1461004657806370a0823114610064578063a9059cbb146100bc575b600080fd5b61004e61010a565b6040518082815260200191505060405180910390f35b6100a66004803603602081101561007a57600080fd5b81019080803573ffffffffffffffffffffffffffffffffffffffff169060200190929190505050610110565b6040518082815260200191505060405180910390f35b610108600480360360408110156100d257600080fd5b81019080803573ffffffffffffffffffffffffffffffffffffffff16906020019092919080359060200190929190505050610128565b005b60015481565b60006020528060005260406000206000915090505481565b806000803373ffffffffffffffffffffffffffffffffffffffff1673ffffffffffffffffffffffffffffffffffffffff16815260200190815260200160002060008282540392505081905550806000808473ffffffffffffffffffffffffffffffffffffffff1673ffffffffffffffffffffffffffffffffffffffff16815260200190815260200160002060008282540192505081905550505056fe";

        uint size = target_bytecode.length;

        assembly{
            target_addr := create(0, 0xa0, size) // 0xa0 was manually computed. It might require different value according to the compiler version
        }
        t = Target(target_addr);
    }

    function transfer(address to, uint amount) public {
        t.transfer(to, amount);
    }

    function echidna_test_balance() public returns(bool){
        return t.balanceOf(address(this)) <= t.totalSupply();
    }
}
```

The proxy:
- Deploy the bytecode in its constructor
- Has one function that will call the target's `transfer` function
- Has one echidna property `t.balanceOf(address(this)) <= t.totalSupply()`

## Run Echidna

```bash
$ echidna-test bytecode_only.sol --contract TestBytecodeOnly
echidna_test_balance: failed!💥  
  Call sequence:
    transfer(0x0,1002)
```

Here Echidna found that by calling `transfer(0 ,1002)` anyone can mint tokens. 

### Target source code

The actual source code of the target is:
```solidity
contract C{
    mapping(address => uint) public balanceOf;
    uint public totalSupply;

    constructor() public{
        balanceOf[msg.sender] = 1000;
        totalSupply = 1000;
    }

    function transfer(address to, uint amount) public{
        balanceOf[msg.sender] -= amount;
        balanceOf[to] += amount;
    }
}
```

Echidna correctly found the bug: lack of overflow checks in `transfer`.

## Differential fuzzing

Consider the following Vyper and Solidity contracts:
```python
@view
@external
def my_func(a: uint256, b: uint256, c: uint256) -> uint256:
    return a * b / c
```

```solidity
contract SolidityVersion{
    function my_func(uint a, uint b, uint c) view public{
        return a * b / c;
    }
}
```

We can test that they return always the same values using the proxy pattern:

```solidity
interface Target{
  function my_func(uint, uint, uint) external returns(uint);
}

contract SolidityVersion{
    Target t;

    constructor() public{
        address target_addr;

        // vyper bytecode
        bytes memory target_bytecode = hex"61007756341561000a57600080fd5b60043610156100185761006d565b600035601c52630ff198a3600051141561006c57600435602435808202821582848304141761004657600080fd5b80905090509050604435808061005b57600080fd5b82049050905060005260206000f350005b5b60006000fd5b61000461007703610004600039610004610077036000f3";

        uint size = target_bytecode.length;

        assembly{
            target_addr := create(0, 0xa0, size) // 0xa0 was manually computed. It might require different value according to the compiler version
        }
        t = Target(target_addr);
    }

    function test(uint a, uint b, uint c) public returns(bool){
        assert(my_func(a, b, c) == t.my_func(a, b, c));
    }

    function my_func(uint a, uint b, uint c) view internal returns(uint){
        return a * b / c;
    }
}
```

Here we run Echidna with the [assertion mode](https://github.com/crytic/building-secure-contracts/blob/master/program-analysis/echidna/assertion-checking.md):
```
$ cat config.yaml 
checkAsserts: true
$ echidna-test  vyper.sol --config config.yaml --contract SolidityVersion
assertion in test: passed! 🎉
```

## Generic Proxy code
Adapt the following code to your needs:
```solidity
interface Target{
  // public/external functions
}

contract TestBytecodeOnly{
    Target t;

    constructor() public{
        address target_addr;
        // init bytecode
        bytes memory target_bytecode = hex"";

        uint size = target_bytecode.length;

        assembly{
            target_addr := create(0, 0xa0, size) // 0xa0 was manually computed. It might require different value according to the compiler version
        }
        t = Target(target_addr);
    }

    // Add helper functions to call the target's functions from the proxy

    function echidna_test() public returns(bool){
      // The property to test
    }
}
```


## Summary: Testing contracts without source code

Echidna can fuzz contracts without source code using a proxy contract. This technique can be also used to compare implementations written in Solidity and Vyper.
