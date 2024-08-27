# How to Test Bytecode-Only Contracts

**Table of contents:**

- [How to Test Bytecode-Only Contracts](#how-to-test-bytecode-only-contracts)
  - [Introduction](#introduction)
  - [Proxy Pattern](#proxy-pattern)
  - [Running Echidna](#running-echidna)
    - [Target Source Code](#target-source-code)
  - [Differential Fuzzing](#differential-fuzzing)
  - [Generic Proxy Code](#generic-proxy-code)
  - [Summary: Testing Contracts Without Source Code](#summary-testing-contracts-without-source-code)

## Introduction

In this tutorial, you'll learn how to fuzz a contract without any provided source code. The technique can also be used to perform differential fuzzing (i.e., compare multiple implementations) between a Solidity contract and a Vyper contract.

Consider the following bytecode:

```
608060405234801561001057600080fd5b506103e86000803373ffffffffffffffffffffffffffffffffffffffff1673ffffffffffffffffffffffffffffffffffffffff168152602001908152602001600020819055506103e86001819055506101fa8061006e6000396000f3fe608060405234801561001057600080fd5b50600436106100415760003560e01c806318160ddd1461004657806370a0823114610064578063a9059cbb146100bc575b600080fd5b61004e61010a565b6040518082815260200191505060405180910390f35b6100a66004803603602081101561007a57600080fd5b81019080803573ffffffffffffffffffffffffffffffffffffffff169060200190929190505050610110565b6040518082815260200191505060405180910390f35b610108600480360360408110156100d257600080fd5b81019080803573ffffffffffffffffffffffffffffffffffffffff16906020019092919080359060200190929190505050610128565b005b60015481565b60006020528060005260406000206000915090505481565b806000803373ffffffffffffffffffffffffffffffffffffffff1673ffffffffffffffffffffffffffffffffffffffff16815260200190815260200160002060008282540392505081905550806000808473ffffffffffffffffffffffffffffffffffffffff1673ffffffffffffffffffffffffffffffffffffffff16815260200190815260200160002060008282540192505081905550505056fe
```

For which we only know the ABI:

```solidity
interface Target {
    function totalSupply() external returns (uint256);

    function balanceOf(address) external returns (uint256);

    function transfer(address, uint256) external;
}
```

We want to test if it is possible to have more tokens than the total supply.

## Proxy Pattern

Since we don't have the source code, we can't directly add the property to the contract. Instead, we'll use a proxy contract:

```solidity
interface Target {
    function totalSupply() external returns (uint256);

    function balanceOf(address) external returns (uint256);

    function transfer(address, uint256) external;
}

contract TestBytecodeOnly {
    Target target;

    constructor() {
        address targetAddress;
        // init bytecode
        bytes
            memory targetCreationBytecode = hex"608060405234801561001057600080fd5b506103e86000803373ffffffffffffffffffffffffffffffffffffffff1673ffffffffffffffffffffffffffffffffffffffff168152602001908152602001600020819055506103e86001819055506101fa8061006e6000396000f3fe608060405234801561001057600080fd5b50600436106100415760003560e01c806318160ddd1461004657806370a0823114610064578063a9059cbb146100bc575b600080fd5b61004e61010a565b6040518082815260200191505060405180910390f35b6100a66004803603602081101561007a57600080fd5b81019080803573ffffffffffffffffffffffffffffffffffffffff169060200190929190505050610110565b6040518082815260200191505060405180910390f35b610108600480360360408110156100d257600080fd5b81019080803573ffffffffffffffffffffffffffffffffffffffff16906020019092919080359060200190929190505050610128565b005b60015481565b60006020528060005260406000206000915090505481565b806000803373ffffffffffffffffffffffffffffffffffffffff1673ffffffffffffffffffffffffffffffffffffffff16815260200190815260200160002060008282540392505081905550806000808473ffffffffffffffffffffffffffffffffffffffff1673ffffffffffffffffffffffffffffffffffffffff16815260200190815260200160002060008282540192505081905550505056fe";

        uint256 size = targetCreationBytecode.length;

        assembly {
            targetAddress := create(0, add(targetCreationBytecode, 0x20), size) // Skip the 32 bytes encoded length.
        }

        target = Target(targetAddress);
    }

    function transfer(address to, uint256 amount) public {
        target.transfer(to, amount);
    }

    function echidna_test_balance() public returns (bool) {
        return target.balanceOf(address(this)) <= target.totalSupply();
    }
}
```

The proxy:

- Deploys the bytecode in its constructor
- Has one function that calls the target's `transfer` function
- Has one Echidna property `target.balanceOf(address(this)) <= target.totalSupply()`

## Running Echidna

```bash
echidna bytecode_only.sol --contract TestBytecodeOnly
echidna_test_balance: failed!💥
  Call sequence:
    transfer(0x0,1002)
```

Here, Echidna found that by calling `transfer(0, 1002)` anyone can mint tokens.

### Target Source Code

The actual source code of the target is:

```solidity
contract C {
    mapping(address => uint256) public balanceOf;
    uint256 public totalSupply;

    constructor() public {
        balanceOf[msg.sender] = 1000;
        totalSupply = 1000;
    }

    function transfer(address to, uint256 amount) public {
        balanceOf[msg.sender] -= amount;
        balanceOf[to] += amount;
    }
}
```

Echidna correctly found the bug: lack of overflow checks in `transfer`.

## Differential Fuzzing

Consider the following Vyper and Solidity contracts:

```vyper
@view
@external
def my_func(a: uint256, b: uint256, c: uint256) -> uint256:
    return a * b / c
```

```solidity
contract SolidityVersion {
    function my_func(uint256 a, uint256 b, uint256 c) public view {
        return (a * b) / c;
    }
}
```

We can test that they always return the same values using the proxy pattern:

```solidity
interface Target {
    function my_func(uint256, uint256, uint256) external returns (uint256);
}

contract SolidityVersion {
    Target target;

    constructor() public {
        address targetAddress;

        // vyper bytecode
        bytes
            memory targetCreationBytecode = hex"61007756341561000a57600080fd5b60043610156100185761006d565b600035601c52630ff198a3600051141561006c57600435602435808202821582848304141761004657600080fd5b80905090509050604435808061005b57600080fd5b82049050905060005260206000f350005b5b60006000fd5b61000461007703610004600039610004610077036000f3";

        uint256 size = targetCreationBytecode.length;

        assembly {
            targetAddress := create(0, add(targetCreationBytecode, 0x20), size) // Skip the 32 bytes encoded length.
        }
        target = Target(targetAddress);
    }

    function test(uint256 a, uint256 b, uint256 c) public returns (bool) {
        assert(my_func(a, b, c) == target.my_func(a, b, c));
    }

    function my_func(uint256 a, uint256 b, uint256 c) internal view returns (uint256) {
        return (a * b) / c;
    }
}
```

Here we run Echidna with the [assertion mode](../basic/assertion-checking.md):

```
echidna  vyper.sol --config config.yaml --contract SolidityVersion --test-mode assertion
assertion in test: passed! 🎉
```

## Generic Proxy Code

Adapt the following code to your needs:

```solidity
interface Target {
    // public/external functions
}

contract TestBytecodeOnly {
    Target target;

    constructor() public {
        address targetAddress;
        // init bytecode
        bytes memory targetCreationBytecode = hex"";

        uint256 size = targetCreationBytecode.length;

        assembly {
            targetAddress := create(0, add(targetCreationBytecode, 0x20), size) // Skip the 32 bytes encoded length.
        }
        target = Target(targetAddress);
    }

    // Add helper functions to call the target's functions from the proxy

    function echidna_test() public returns (bool) {
        // The property to test
    }
}
```

## Summary: Testing Contracts Without Source Code

Echidna can fuzz contracts without source code using a proxy contract. This technique can also be used to compare implementations written in Solidity and Vyper.
